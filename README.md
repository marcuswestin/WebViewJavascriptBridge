WebViewJavascriptBridge
=======================

An iOS bridge for sending messages to and from javascript in a UIWebView

Getting started
---------------

Just open the xcode project (requires xcode > 4.2) and hit run to see the example application work.

Usage
-----

See WebViewJavascriptBridge/AppDelegate.* and WebViewJavascriptBridge/ExampleWebViewJavascriptBridgeDelegate.* for example code that works. Or, follow these steps:

1) Copy `Classes/WebViewJavascriptBridge.h` and `Classes/WebViewJavascriptBridge.m` into your xcode project

2) Instantiate a webview, a javascript bridge, and set yourself as the bridge's delegate

	#import <Foundation/Foundation.h>
	#import "WebViewJavascriptBridge.h"

	@interface ExampleAppDelegate : UIResponder <UIApplicationDelegate, WebViewJavascriptBridgeDelegate>
	
	@end
	
	@implementation ExampleAppDelegate
	
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
	    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	    [self.window makeKeyAndVisible];
		
		webView = [[UIWebView alloc] initWithFrame:self.window.bounds];
	    [self.window addSubview:webView];
	    javascriptBridge = [WebViewJavascriptBridge createWithDelegate:self];
	    webView.delegate = javascriptBridge;
	}

	- (void) handleMessage:(NSString *)message {
	    NSLog(@"MyJavascriptBridgeDelegate received message: %@", message);
	}

	@end

3) Go ahead and send some messages from objc to javascript

	[javascriptBridge sendMessage:@"Well hello there"];

4) Finally, set up the javascript side of things
	
	document.addEventListener('WebViewJavascriptBridgeReady', function() {
		WebViewJavascriptBridge.setMessageHandler(function(message) {
			alert("Got message from ObjC: " + message)
		});
		WebViewJavascriptBridge.sendMessage('Right back atcha from the JS!');
	}, false)
