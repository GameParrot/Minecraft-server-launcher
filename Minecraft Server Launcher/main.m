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
NSLog(theLog);
}

@end
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
    }
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, argv);
}
