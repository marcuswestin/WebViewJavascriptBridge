#import "ExampleAppDelegate.h"

@implementation ExampleAppDelegate

@synthesize window = _window;
@synthesize webView = _webView;
@synthesize javascriptBridge = _javascriptBridge;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.webView = [[UIWebView alloc] initWithFrame:self.window.bounds];
    [self.window addSubview:self.webView];

	self.javascriptBridge = [WebViewJavascriptBridge javascriptBridgeWithDelegate:self];
	self.webView.delegate = self.javascriptBridge;
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setTitle:@"Send message" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.window insertSubview:button aboveSubview:self.webView];
	button.frame = CGRectMake(95, 400, 130, 45);
    
    // register a callback
    [self.javascriptBridge registerJavascriptCallback:@"testCallback" withCallback:^(NSDictionary *params){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Javascript Callback" message:[NSString stringWithFormat:@"params: %@", params] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
	
	[self.javascriptBridge sendMessage:@"Message from ObjC before Webview is complete!" toWebView:self.webView];
	
	[self loadExamplePage];
	
	[self.javascriptBridge sendMessage:@"Message 2 from ObjC before Webview is complete!" toWebView:self.webView];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)buttonPressed:(id)sender {
    [self.javascriptBridge sendMessage:@"Message from ObjC on normal situations!" toWebView:self.webView];
}

- (void)javascriptBridge:(WebViewJavascriptBridge *)bridge receivedMessage:(NSString *)message fromWebView:(UIWebView *)webView {
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
         "      button.onclick = button.ontouchstart = function() { WebViewJavascriptBridge.sendMessage('hello from JS button'); };"
         "      WebViewJavascriptBridge.callCallback('testCallback', {'arg1': 'foo', 'arg2': 'bar'});"
         "  }"
         "  </script>"
         "</body></html>" baseURL:nil];
}

@end
