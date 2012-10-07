#import "ExampleAppDelegate.h"

@implementation ExampleAppDelegate

@synthesize window = _window;
@synthesize javascriptBridge = _bridge;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.window.bounds];
    [self.window addSubview:webView];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:webView handler:^(id data, WVJBResponse *response) {
        NSLog(@"ObjC received message from JS: %@", data);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ObjC got message from Javascript:" message:data delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
    [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponse *response) {
        NSLog(@"testObjcCallback called: %@", data);
        [response respondWith:@"Response from testObjcCallback"];
    }];
    
    [_bridge send:@"A string sent from ObjC before Webview has loaded." responseCallback:^(id error, id responseData) {
        if (error) { return NSLog(@"Uh oh - I got an error: %@", error); }
        NSLog(@"objc got response! %@ %@", error, responseData);
    }];
    
    [_bridge callHandler:@"testJavascriptHandler" data:[NSDictionary dictionaryWithObject:@"before ready" forKey:@"foo"]];
    
    [self renderButtons:webView];
    [self loadExamplePage:webView];
    
    [_bridge send:@"A string sent from ObjC after Webview has loaded."];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)renderButtons:(UIWebView*)webView {
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[messageButton setTitle:@"Send message" forState:UIControlStateNormal];
	[messageButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
	[self.window insertSubview:messageButton aboveSubview:webView];
	messageButton.frame = CGRectMake(20, 414, 130, 45);
    
    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"Call handler" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.window insertSubview:callbackButton aboveSubview:webView];
	callbackButton.frame = CGRectMake(170, 414, 130, 45);
}

- (void)sendMessage:(id)sender {
    [_bridge send:@"A string sent from ObjC to JS"];
}

- (void)callHandler:(id)sender {
    [_bridge callHandler:@"testJavascriptHandler" data:[NSDictionary dictionaryWithObject:@"Hi there, JS!" forKey:@"greetingFromObjC"] responseCallback:^(id error, id response) {
        NSLog(@"testJavascriptHandler responded: %@ %@", error, response);
    }];
}

- (void)loadExamplePage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [webView loadHTMLString:appHtml baseURL:nil];
}

@end
