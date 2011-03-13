
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "JSConsole.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSWindow *window;
  WebView *webView;
  JSConsole *console;
  NSArray *userScripts;
}

- (int)checkPermission;
- (WebScriptObject *)createNotificationWithIcon:(NSString *)icon title:(NSString *)title message:(NSString *)message;
- (void)requestPermissionWithCallback:(WebScriptObject *)callback;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet WebView *webView;


@end
