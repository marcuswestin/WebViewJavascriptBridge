#import <UIKit/UIKit.h>
#import <TargetConditionals.h>
#import <dlfcn.h>
#import "ExampleAppDelegate.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

int main(int argc, char * argv[])
{
    @autoreleasepool {
        // Dynamically load WebKit if iOS version >= 8
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
#if TARGET_IPHONE_SIMULATOR
            NSString *frameworkPath = [[NSProcessInfo processInfo] environment][@"DYLD_FALLBACK_FRAMEWORK_PATH"];
            if (frameworkPath) {
                NSString *webkitLibraryPath = [NSString pathWithComponents:@[frameworkPath, @"WebKit.framework", @"WebKit"]];
                dlopen([webkitLibraryPath cStringUsingEncoding:NSUTF8StringEncoding], RTLD_LAZY);
            }
#else
            dlopen("/System/Library/Frameworks/WebKit.framework/WebKit", RTLD_LAZY);
#endif
        }
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([ExampleAppDelegate class]));
    }
}