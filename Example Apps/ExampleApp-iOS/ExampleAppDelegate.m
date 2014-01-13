#import "ExampleAppDelegate.h"
#import "ExampleAppViewController.h"

@implementation ExampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [ExampleAppViewController new];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
