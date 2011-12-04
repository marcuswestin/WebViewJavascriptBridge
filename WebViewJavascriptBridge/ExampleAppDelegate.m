#import "ExampleAppDelegate.h"

@implementation ExampleAppDelegate

@synthesize window = _window;
@synthesize webView = _webView;
@synthesize javascriptBridge = _javascriptBridge;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.webView = [[UIWebView alloc] initWithFrame:self.window.bounds];
    [self.window addSubview:self.webView];

    self.javascriptBridge = [WebViewJavascriptBridge javascriptBridgeWithDelegate:self];
    self.webView.delegate = self.javascriptBridge;
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setTitle:@"Send message" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.window insertSubview:button aboveSubview:self.webView];
	button.frame = CGRectMake(90, 400, 130, 45);
	
	[self.javascriptBridge sendMessage:@"Message from ObjC before Webview is complete!" toWebView:self.webView];
    
    [self loadExamplePage];
    
    [self.javascriptBridge sendMessage:@"Message 2 from ObjC before Webview is complete!" toWebView:self.webView];

	[self.window makeKeyAndVisible];
    return YES;
}

- (void)buttonPressed:(id)sender
{
	[self.javascriptBridge sendMessage:@"Message from ObjC on normal situations!" toWebView:self.webView];
}

- (void)javascriptBridge:(WebViewJavascriptBridge *)bridge receivedMessage:(NSString *)message fromWebView:(UIWebView *)webView
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message from Javascript" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

- (void)loadExamplePage {
    [self.webView loadHTMLString:@""
     "<!doctype html>"
     "<html><head>"
     "  <style type='text/css'>h1 { color:red; }</style>"
     "</head><body>"
     "  <h1>Javascript Bridge Demo</h1>"
     "  <script>"
     "  document.addEventListener('WebViewJavascriptBridgeReady', onBridgeReady, false);"
     "  function onBridgeReady() {"
     "      WebViewJavascriptBridge.setMessageHandler(function(message) {"
     "          var el = document.body.appendChild(document.createElement('div'));"
     "          el.innerHTML = message;"
     "      });"
     "      WebViewJavascriptBridge.sendMessage('hello from the JS');"
     "      var button = document.body.appendChild(document.createElement('button'));"
     "      button.innerHTML = 'Click me to send a message to ObjC';"
     "      button.onclick = function() { WebViewJavascriptBridge.sendMessage('hello from JS button'); };"
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
