#import "ExampleAppDelegate.h"

@implementation ExampleAppDelegate

@synthesize window = _window;
@synthesize javascriptBridge = _javascriptBridge;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.window.bounds];
    [self.window addSubview:webView];
    
    self.javascriptBridge = [WebViewJavascriptBridge javascriptBridgeForWebView:webView handler:^(id data, WVJBResponseCallback responseCallback) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message from Javascript" message:data delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
    [self.javascriptBridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];
    
    [self.javascriptBridge send:@"A string sent from ObjC before Webview has loaded."];
    [self.javascriptBridge callHandler:@"testJavascriptHandler" data:[NSDictionary dictionaryWithObject:@"before ready" forKey:@"foo"]];
    
    [self renderButtons:webView];
    [self loadExamplePage:webView];
    
    [self.javascriptBridge send:@"A string sent from ObjC after Webview has loaded."];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)renderButtons:(UIWebView*)webView {
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[messageButton setTitle:@"Send message" forState:UIControlStateNormal];
	[messageButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
	[self.window insertSubview:messageButton aboveSubview:webView];
	messageButton.frame = CGRectMake(20, 400, 130, 45);
    
    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"Call handler" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.window insertSubview:callbackButton aboveSubview:webView];
	callbackButton.frame = CGRectMake(170, 400, 130, 45);
}

- (void)sendMessage:(id)sender {
    [self.javascriptBridge send:@"A string sent from ObjC to JS"];
}

- (void)callHandler:(id)sender {
    [self.javascriptBridge callHandler:@"testJavascriptHandler" data:[NSDictionary dictionaryWithObject:@"Hi there, JS!" forKey:@"greetingFromObjC"] responseCallback:^(id data) {
        NSLog(@"testJavascriptHandler responded: %@", data);
    }];
}

- (void)loadExamplePage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [webView loadHTMLString:appHtml baseURL:nil];
}

@end
