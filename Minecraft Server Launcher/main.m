//
//  main.m
//  Minecraft Server Launcher
//
//  Created by GameParrot on 8/24/21.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>
#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
@interface NoTimestampLog : NSObject

@end
@implementation NoTimestampLog

+(void)notimestamp:(NSString *)theLog
{
NSLog(@"%@", theLog);
}
@end
int main(int argc, const char * argv[]) {
    @try {
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        if( [arguments[1] isEqualToString:@"-h"] || [arguments[1] isEqualToString:@"--help"]) {
            NSLog(@"usage: Minecraft Server Launcher [-launch servername] [-edit servername edit_id value]");
            NSLog(@"To launch a server from the command line, use -launch servername");
            NSLog(@"To edit a server from the command line, use -edit servername [UIElement <0> <1>] [NoGUI <0> <1>] [Delete] [changeVersion <version>]");
            exit(0);
        }
        if( ![arguments[1] isEqualToString:@"-launch"] && ![arguments[1] isEqualToString:@"-edit"]) {
            NSLog(@"Ignored Argument: %@", arguments[1])
        }
    }
    @catch (NSException * e) {
    }
    @finally {
    }
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
    }
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, argv);
}
