//
//  JSConsole.m
//  irccloudapp
//
//  Created by Johan Nordberg on 2011-03-11.
//  Copyright 2011 FFFF00 Agents AB. All rights reserved.
//

#import "JSConsole.h"

typedef enum {
  JSLogLevelInfo,
  JSLogLevelWarn,
  JSLogLevelError,
} JSLogLevel;

@interface JSConsole (PrivateMethods)
- (NSString *)stringFromWebScriptObject:(WebScriptObject *)wsObj;
- (void)log:(id)value level:(JSLogLevel)level;
@end

@implementation JSConsole

- (NSString *)stringFromWebScriptObject:(WebScriptObject *)wsObj {
  return [wsObj callWebScriptMethod:@"toString" withArguments:nil];
}

- (void)log:(id)value level:(JSLogLevel)level {
  NSString *message;

  if ([value isMemberOfClass:[WebScriptObject class]]) {
    message = [self stringFromWebScriptObject:(WebScriptObject *)value];
  } else if ([value isMemberOfClass:[NSString class]]) {
    message = (NSString *)value;
  } else {
    message = [value stringRepresentation];
  }

  NSString *levelStr;

  switch (level) {
    case JSLogLevelInfo:
      levelStr = @"INFO: ";
      break;
    case JSLogLevelWarn:
      levelStr = @"WARNING: ";
      break;
    case JSLogLevelError:
      levelStr = @"ERROR: ";
      break;
    default:
      levelStr = @"UNKNOWN: ";
      break;
  }

  NSLog(@"%@", [levelStr stringByAppendingString:message]);
}
                                                                
- (void)consoleLog:(id)value {
  [self log:value level:JSLogLevelInfo];
}

- (void)consoleWarn:(id)value {
  [self log:value level:JSLogLevelWarn];
}

- (void)consoleError:(id)value {
  [self log:value level:JSLogLevelError];
}

#pragma mark -

+ (NSString *)webScriptNameForSelector:(SEL)sel {
  if (sel == @selector(consoleLog:)) {
    return @"log";
  } else if (sel == @selector(consoleWarn:)) {
    return @"warn";
  } else if (sel == @selector(consoleError:)) {
    return @"error";
  }
  return nil;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel {
  if (sel == @selector(consoleLog:) ||
      sel == @selector(consoleWarn:) ||
      sel == @selector(consoleError:)) {
    return NO;
  }
  return YES;
}

#pragma mark -

- (void)dealloc {
  [super dealloc];
}

@end
