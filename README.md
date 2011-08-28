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

2) `#import "WebViewJavascriptBridge.h"`

3) Implement your javascript bridge delegate - it will handle all messages sent from the javascript
	
	// MyJavascriptBridgeDelegate.h
	#import <Foundation/Foundation.h>
	#import "WebViewJavascriptBridge.h"

	@interface MyJavascriptBridgeDelegate : NSObject <WebViewJavascriptBridgeDelegate>

	@end
	
	// MyJavascriptBridgeDelegate.m
	@implementation MyJavascriptBridgeDelegate
	
	- (void) handleMessage:(NSString *)message {
	    NSLog(@"MyJavascriptBridgeDelegate received message: %@", message);
	}

	@end

4) Instantiate a bridge, your delegate, and assign it to the web view
	
	UIWebView *theWebView = ...;
	javascriptBridgeDelegate = [[ExampleWebViewJavascriptBridgeDelegate alloc] init];
	javascriptBridge = [MyJavascriptBridgeDelegate createWithDelegate:javascriptBridgeDelegate];
	theWebView.delegate = javascriptBridge;

5) Send some messages from objc to javascript

	[javascriptBridge sendMessage:@"Well hello there"];

6) Finally, set up the javascript side of things
	
	document.addEventListener('WebViewJavascriptBridgeReady', function() {
		WebViewJavascriptBridge.setMessageHandler(function(message) {
			alert("Got message from ObjC: " + message)
		});
		WebViewJavascriptBridge.sendMessage('Right back atcha from the JS!');
	}, false)
