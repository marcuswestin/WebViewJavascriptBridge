#import "ExampleAppDelegate.h"

@implementation ExampleAppDelegate

@synthesize window = _window;
@synthesize webView = _webView;
@synthesize javascriptBridge = _javascriptBridge;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.webView = [[UIWebView alloc] initWithFrame:self.window.bounds];
    [self.window addSubview:self.webView];

    self.javascriptBridge = [WebViewJavascriptBridge javascriptBridgeForWebView:self.webView handler:^(id data, WVJBCallback callback) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message from Javascript" message:data delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
    
    [self renderButtons];
    
    // register a callback
    [self.javascriptBridge registerHandler:@"testObjcCallback" callback:^(id data, WVJBCallback callback) {
        NSLog(@"testObjcCallback called: %@", data);
        callback(@"Response from testObjcCallback");
    }];

    [self.javascriptBridge send:@"A string sent from ObjC before Webview has loaded."];
    [self.javascriptBridge callHandler:@"testJavascriptHandler" data:[NSDictionary dictionaryWithObject:@"before ready" forKey:@"foo"]];
    
    [self loadExamplePage];

    [self.javascriptBridge send:@"A string sent from ObjC after Webview has loaded."];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)renderButtons {
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[messageButton setTitle:@"Send message" forState:UIControlStateNormal];
	[messageButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
	[self.window insertSubview:messageButton aboveSubview:self.webView];
	messageButton.frame = CGRectMake(20, 400, 130, 45);
    
    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"Call handler" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.window insertSubview:callbackButton aboveSubview:self.webView];
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

- (void)loadExamplePage {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:appHtml baseURL:nil];
}

@end
