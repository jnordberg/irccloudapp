#import "AppDelegate.h"

@interface AppDelegate (PrivateMethods)
- (void)loadUserScripts;
- (void)handleNetworkErrorForWebView:(WebView *)webView;
@end

@implementation AppDelegate

@synthesize window, webView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification { 
  [webView setFrameLoadDelegate:self];
  [webView setPolicyDelegate:self];
  [webView setUIDelegate:self];

  // webview -> notification center bridge
  notificationProvider = [[NotificationProvider alloc] init];
  [webView _setNotificationProvider:notificationProvider];

  // user agent
  NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  [webView setApplicationNameForUserAgent:[NSString stringWithFormat:@"nimbus/%@", version]];

  // listen for title changes
  [webView addObserver:self
            forKeyPath:@"mainFrameTitle"
               options:NSKeyValueObservingOptionNew
               context:NULL];

  console = [[JSConsole alloc] init];

  [self loadUserScripts];

  [[NSURLCache sharedURLCache] removeAllCachedResponses];

  url = [[NSUserDefaults standardUserDefaults] valueForKey:@"url"];
  if (!url) url = @"https://www.irccloud.com/";

  NSLog(@"Connecting to %@", url);

  [webView setMainFrameURL:url];
}

#pragma mark -

- (void)loadUserScripts {
  NSFileManager *fileManager = [NSFileManager defaultManager];

  NSString *folder = @"~/Library/Application Support/nimbus/Scripts/";
  folder = [folder stringByExpandingTildeInPath];

  if ([fileManager fileExistsAtPath:folder] == NO) {
    [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:NULL];
  }

  NSArray *files = [fileManager contentsOfDirectoryAtPath:folder error:NULL];
  NSMutableArray *scripts = [[NSMutableArray alloc] initWithCapacity:[files count]];

  for (NSString* file in files) {
    [scripts addObject:[folder stringByAppendingPathComponent:file]];
  }

  userScripts = [[NSArray alloc] initWithArray:scripts];
  [scripts release];
}

#pragma mark -

- (void)titleDidChange:(NSString *)title {
  NSUInteger unread = 0;

  if ([title length] == 0) {
    NSLog(@"WARNING: title changed to an empty string.");
    return;
  }
  if ([[title substringToIndex:1] isEqualToString:@"*"]) {
    title = [title substringFromIndex:2];
  } else if ([[title substringToIndex:1] isEqualToString:@"("]) {
    NSRange range = [title rangeOfString:@")"];
    range.length = range.location - 1;
    range.location = 1;
    unread = [[title substringWithRange:range] intValue];
    title = [title substringFromIndex:range.location + range.length + 2];
  }

  NSString *badge = nil;
  if (unread > 0) {
    badge = [NSString stringWithFormat:@"%ld", unread];
  }

  NSRange pipepos = [title rangeOfString:@" | IRCCloud" options:NSBackwardsSearch];
  if (pipepos.location != NSNotFound) {
    title = [title substringToIndex:pipepos.location];
  }

  [[[NSApplication sharedApplication] dockTile] setBadgeLabel:badge];
  [window setTitle:title];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if ([keyPath isEqualToString:@"mainFrameTitle"]) {
    [self titleDidChange:[change valueForKey:@"new"]];
  }
}

#pragma mark FrameLoadDelegate

- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowScriptObject forFrame:(WebFrame *)frame {
  [windowScriptObject setValue:console forKey:@"console"];

  // inject userscripts
  for (NSString *script in userScripts) {
    NSLog(@"loading script: %@", script);
    [windowScriptObject evaluateWebScript:[NSString stringWithContentsOfFile:script usedEncoding:nil error:NULL]];
  }
}

- (void)handleNetworkErrorForWebView:(WebView *)view {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Unable to connect to IRCCloud" defaultButton:@"Retry" alternateButton:@"Quit" otherButton:nil informativeTextWithFormat:@"Check your internet connection."];
    [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse responseCode) {
        if (responseCode == NSModalResponseOK) {
            [view setMainFrameURL:url];
        } else {
            [NSApp stop:self];
        }
    }];
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
    [self handleNetworkErrorForWebView:sender];
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
    [self handleNetworkErrorForWebView:sender];
}

#pragma mark WebPolicyDelegate

- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request
   newFrameName:(NSString *)frameName decisionListener:(id <WebPolicyDecisionListener>)listener {
  // route all links that request a new window to default browser
  [listener ignore];
  [[NSWorkspace sharedWorkspace] openURL:[request URL]];
}

#pragma mark WebUIDelegate

- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Please confirm" defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:@"%@", message];
    return [alert runModal] == NSAlertDefaultReturn;
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Nimbus" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", message];
    [alert runModal];
}

- (void)webView:(WebView *)webView addMessageToConsole:(NSDictionary *)dictionary {
  NSLog(@"ERROR: %@", [dictionary objectForKey:@"message"]);
}

#pragma mark -

- (void)dealloc {
  [console release];
  [notificationProvider release];
  [userScripts release];
  [super dealloc];
}

@end
