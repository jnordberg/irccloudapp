
#import <Cocoa/Cocoa.h>

#import "JSConsole.h"
#import "NotificationProvider.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, WebFrameLoadDelegate, WebUIDelegate, WebPolicyDelegate> {
  NSWindow *window;
  WebView *webView;
  JSConsole *console;
  NotificationProvider *notificationProvider;
  NSArray *userScripts;
  NSString *url;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet WebView *webView;

@end
