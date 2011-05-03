//
//  Notification.m
//  irccloudapp
//
//  Created by Johan Nordberg on 2011-03-13.
//  Copyright 2011 FFFF00 Agents AB. All rights reserved.
//

#import "Notification.h"
#import <Growl/Growl.h>

@implementation Notification

@synthesize ondisplay, onerror, onclose;

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
  if ((self = [self init])) {
    _title = [title retain];
    _message = [message retain];
  }
  return self;
}

- (void)show {
  // TODO: subclass Notification for growl integration instead.
  //       also keep track of notifications and post onclose event appropriately

  [GrowlApplicationBridge notifyWithTitle:_title
                              description:_message
                         notificationName:@"Message"
                                 iconData:nil
                                 priority:0
                                 isSticky:NO
                             clickContext:nil
                               identifier:[NSString stringWithFormat:@"%p", self]];

  if (ondisplay && [ondisplay isMemberOfClass:[WebScriptObject class]]) {
    [ondisplay callWebScriptMethod:@"call" withArguments:nil];
  }
}

- (void)cancel {
  // TODO
}

+ (BOOL)isKeyExcludedFromWebScript:(const char *)name {
  NSString *str = [[[NSString alloc] initWithCString:name encoding:NSASCIIStringEncoding] autorelease];
  if ([str isEqualToString:@"ondisplay"] || [str isEqualToString:@"onclose"] ||
      [str isEqualToString:@"onerror"]) {
    return NO;
  }
  return YES;
}

+ (NSString *)webScriptNameForSelector:(SEL)sel {
  if (sel == @selector(show)) {
    return @"show";
  } else if (sel == @selector(cancel)) {
    return @"cancel";
  }
  return nil;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel {
  if (sel == @selector(show) || sel == @selector(cancel)) {
    return NO;
  }
  return YES;
}

- (void)dealloc {
  [_title release];
  [_message release];
  [ondisplay release];
  [onclose release];
  [onerror release];
  [super dealloc];
}

@end
