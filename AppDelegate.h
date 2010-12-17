
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSWindow *window;
}

- (int)checkPermission;
- (void)createNotificationWithIcon:(NSString *)icon title:(NSString *)title message:(NSString *)message;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet WebView *webView;


@end
