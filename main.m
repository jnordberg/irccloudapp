
#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[]) {
  id pool = [NSAutoreleasePool new];

  NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Logs/irccloudapp.log"];
  freopen([logPath fileSystemRepresentation], "a", stderr);

  [pool release];

  return NSApplicationMain(argc,  (const char **) argv);
}
