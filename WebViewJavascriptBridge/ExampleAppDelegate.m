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
	
	UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[messageButton setTitle:@"Send message" forState:UIControlStateNormal];
	[messageButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.window insertSubview:messageButton aboveSubview:self.webView];
	messageButton.frame = CGRectMake(20, 400, 130, 45);
    
    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"Call callback" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callbackPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.window insertSubview:callbackButton aboveSubview:self.webView];
	callbackButton.frame = CGRectMake(170, 400, 130, 45);
    
    // register a callback
    [self.javascriptBridge registerObjcCallback:@"testObjcCallback" withCallback:^(NSDictionary *params){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Javascript called Objc callback"
                                                        message:[NSString stringWithFormat:@"params: %@", params]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
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

- (void)callbackPressed:(id)sender {
    [self.javascriptBridge callJavascriptCallback:@"testJsCallback"
                                     withParams:[NSDictionary dictionaryWithObjectsAndKeys:@"bar", @"foo", nil]
                                      toWebView:self.webView];
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
         "      WebViewJavascriptBridge.callObjcCallback('testObjcCallback', {'arg1': 'foo', 'arg2': 'bar'});"
         "      WebViewJavascriptBridge.registerJsCallback('testJsCallback', function(params) {"
         "          var el = document.body.appendChild(document.createElement('div'));"
         "          el.innerHTML = 'Callback called foo is [' + params.foo + ']';"
         "      });"
         "  }"
         "  </script>"
         "</body></html>" baseURL:nil];
}

@end
