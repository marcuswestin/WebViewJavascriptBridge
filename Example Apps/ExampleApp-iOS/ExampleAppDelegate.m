#import "ExampleAppDelegate.h"
#import "ExampleUIWebViewController.h"
#import "ExampleWKWebViewController.h"

@implementation ExampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    ExampleUIWebViewController* UIWebViewExampleController = [[ExampleUIWebViewController alloc] init];
    UIWebViewExampleController.tabBarItem.title             = @"UIWebView";
    
    ExampleWKWebViewController* WKWebViewExampleController = [[ExampleWKWebViewController alloc] init];
    WKWebViewExampleController.tabBarItem.title             = @"WKWebView";
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [tabBarController addChildViewController:UIWebViewExampleController];
    [tabBarController addChildViewController:WKWebViewExampleController];

    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
