//
//  Notification.h
//  irccloudapp
//
//  Created by Johan Nordberg on 2011-03-13.
//  Copyright 2011 FFFF00 Agents AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface Notification : NSObject {
  NSString *_title;
  NSString *_message;

  WebScriptObject *ondisplay;
  WebScriptObject *onerror;
  WebScriptObject *onclose;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message;

- (void)show;
- (void)cancel;

@property (nonatomic, retain) WebScriptObject *ondisplay;
@property (nonatomic, retain) WebScriptObject *onerror;
@property (nonatomic, retain) WebScriptObject *onclose;

@end
