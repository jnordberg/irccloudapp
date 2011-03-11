//
//  JSConsole.h
//  irccloudapp
//
//  Created by Johan Nordberg on 2011-03-11.
//  Copyright 2011 FFFF00 Agents AB. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface JSConsole : NSObject {
}

- (void)consoleLog:(id)value;
- (void)consoleWarn:(id)value;
- (void)consoleError:(id)value;

@end
