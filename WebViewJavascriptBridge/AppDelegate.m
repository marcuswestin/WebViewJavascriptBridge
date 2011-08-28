#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize webView;
@synthesize javascriptBridge;
@synthesize javascriptBridgeDelegate;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];

    webView = [[UIWebView alloc] initWithFrame:self.window.bounds];
    [self.window addSubview:webView];

    javascriptBridgeDelegate = [[ExampleWebViewJavascriptBridgeDelegate alloc] init];
    javascriptBridge = [WebViewJavascriptBridge createWithDelegate:javascriptBridgeDelegate];
    webView.delegate = javascriptBridge;

    [javascriptBridge sendMessage:@"HI"];
    
    [self loadExamplePage];
    
    [javascriptBridge sendMessage:@"HI2"];

    return YES;
}

- (void) loadExamplePage {
    [webView loadHTMLString:@""
     "<!doctype html>"
     "<html><head>"
     "  <style type='text/css'>h1 { color:red; }</style>"
     "</head><body>"
     "  <h1>hi</h1>"
     "  <script>"
     "  document.addEventListener('WebViewJavascriptBridgeReady', onBridgeReady, false);"
     "  function onBridgeReady() {"
     "      WebViewJavascriptBridge.setMessageHandler(function(message) {"
     "          var el = document.body.appendChild(document.createElement('div'));"
     "          el.innerHTML = message;"
     "      });"
     "      WebViewJavascriptBridge.sendMessage('hello from the JS');"
     "  }"
     "  </script>"
     "</body></html>" baseURL:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
