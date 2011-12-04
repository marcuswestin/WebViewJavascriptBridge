WebViewJavascriptBridge
=======================

An iOS bridge for sending messages to and from javascript in a UIWebView

Getting started
---------------

Just open the Xcode project (requires Xcode > 4.2) and hit run to see the example application work.

Usage
-----

See ExampleAppDelegate.* for example code. To use it in your own project:

1) Copy `Classes/WebViewJavascriptBridge.h` and `Classes/WebViewJavascriptBridge.m` into your Xcode project

2) Instantiate a UIWebView, a WebViewJavascriptBridge, and set yourself as the bridge's delegate

	#import <UIKit/UIKit.h>
	#import "WebViewJavascriptBridge.h"

	@interface ExampleAppDelegate : UIResponder <UIApplicationDelegate, WebViewJavascriptBridgeDelegate>
	
	@end
	
	@implementation ExampleAppDelegate
	
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
	    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		
		self.webView = [[UIWebView alloc] initWithFrame:self.window.bounds];
	    [self.window addSubview:webView];
	    self.javascriptBridge = [WebViewJavascriptBridge javascriptBridgeWithDelegate:self];
	    self.webView.delegate = javascriptBridge;
		
		[self.window makeKeyAndVisible];
		return YES;
	}

	- (void)javascriptBridge:(WebViewJavascriptBridge *)bridge receivedMessage:(NSString *)message fromWebView:(UIWebView *)webView 
	{
	    NSLog(@"MyJavascriptBridgeDelegate received message: %@", message);
	}

	@end

3) Go ahead and send some messages from Objc to javascript

	[self.javascriptBridge sendMessage:@"Well hello there" toWebView:self.webView];

4) Finally, set up the javascript side of things
	
	document.addEventListener('WebViewJavascriptBridgeReady', function onBridgeReady() {
		WebViewJavascriptBridge.setMessageHandler(function(message) {
			alert('Received message: ' + message)
		})
		WebViewJavascriptBridge.sendMessage('Hello from the javascript')
	}, false)
	
ARC
---
If you're using ARC in your project, add `-fno-objc-arc` as a compiler flag to the `WebViewJavascriptBridge.m` file.

Contributors
------------

- [@marcuswestin](https://github.com/marcuswestin) Marcus Westin
- [@psineur](https://github.com/psineur) Stepan Generalov
- [@sergiocampama](https://github.com/sergiocampama) Sergio Campamá

