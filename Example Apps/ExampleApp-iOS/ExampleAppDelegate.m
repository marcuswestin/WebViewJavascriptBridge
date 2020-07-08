#import "ExampleAppDelegate.h"
#import "ExampleWKWebViewController.h"

@implementation ExampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    ExampleWKWebViewController* WKWebViewExampleController = [[ExampleWKWebViewController alloc] init];
    WKWebViewExampleController.tabBarItem.title = @"WKWebView";
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = WKWebViewExampleController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
