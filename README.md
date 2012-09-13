WebViewJavascriptBridge
=======================

An iOS bridge for sending messages to and from javascript in a UIWebView.

Getting started
---------------

Just open the Xcode project and hit run to see the example application.

Setup your project
------------------

See ExampleApp/* for example code. To use it in your own project:

1) Drag the `WebViewJavascriptBridge` folder into your project.

In the dialog that appears:
- Uncheck "Copy items into destination group's folder (if needed)"
- Select "Create groups for any folders"

2) Import the header file:

	#import "WebViewJavascriptBridge.h"

3) Instantiate a UIWebView and a WebViewJavascriptBridge:

	UIWebView* webView = [[UIWebView alloc] initWithFrame:self.window.bounds];
	WebViewJavascriptBridge* javascriptBridge = [WebViewJavascriptBridge javascriptBridgeForWebView:webView handler:^(id data, WVJBCallback callback) {
		NSLog(@"Received message from javascript: %@", data);
	}];

4) Go ahead and send some messages from Objc to javascript:

	[javascriptBridge send:@"Well hello there"];
	[javascriptBridge send:[NSDictionary dictionaryWithObject:@"Foo" forKey:@"Bar"]];
	[javascriptBridge send:@"Give me a response, will you?" responseCallback:^(id data) {
		NSLog(@"I got a response! %@", data);
	}];

4) Finally, set up the javascript side of things:
	
	document.addEventListener('WebViewJavascriptBridgeReady', function onBridgeReady() {
		WebViewJavascriptBridge.init(function(message, responseCallback) {
			alert('Received message: ' + message)   
			if (responseCallback) {
				responseCallback("Right back atcha")
			}
		})
		WebViewJavascriptBridge.send('Hello from the javascript')
	}, false)

5) Optional API: Registered handlers

This lets you register named handlers for e.g. command handling. You should register handlers 

*Note:* You need to 1) register ObjC handlers before loading the UIWebView, and 2) register javascript handlers before calling `WebViewJavascriptBridge.init`.

In ObjC:
	
	// Register handler
	[javascriptBridge registerHandler:@"greetPerson" responseCallback:^(id data, WVJBCallback callback) {
		callback([NSString stringWithFormat:@"Hello, %@", [data objectForKey:@"name"]]);
	}];
	// Call javascript handlers
	[javascriptBridge callHandler:@"showAlert" data:@"FooBar"];
	[javascriptBridge callHandler:@"getUrl" data:nil callback:^(id data) {
		NSLog(@"UIWebView url is %@", data);
	}];

In javascript:
	
	// Register handlers
	WebViewJavascriptBridge.registerHandler('showAlert', function(data) {
		alert(data)
	})
	WebViewJavascriptBridge.registerHandler('getUrl', function(data, responseCallback) {
		responseCallback(document.location.toString())
	})
	// Call ObjC handler
	WebViewJavascriptBridge.callHandler('greetPerson', { name:'Marcus' }, function responseCallback(data) {
		alert("ObjC created greeting: "+ data)
	})

### iOS4 support (with JSONKit)

	WebViewJavascriptBridge uses `NSJSONSerialization` by default. If you need iOS 4 support then you can use [JSONKit](https://github.com/johnezang/JSONKit/), and add `USE_JSONKIT` to the preprocessor macros for your project.

### ObjC API Reference

- `[WebViewJavascriptBridge javascriptBridgeForWebView:(UIWebView*) handler:(WVJBHandler)]`

Create a javascript bridge for the given webview.

Example:
	
	[WebViewJavascriptBridge javascriptBridgeForWebView:webView handler:^(id data, WVJBCallback responseCallback) {
		NSLog(@"Received message from javascript: %@", data);
		if (responseCallback) {
			responseCallback(@"Right back atcha")
		}
	}]

... More to come soon ...

Contributors
------------

- [@marcuswestin](https://github.com/marcuswestin) Marcus Westin
- [@psineur](https://github.com/psineur) Stepan Generalov
- [@sergiocampama](https://github.com/sergiocampama) Sergio Campamá
- [@stringbean](https://github.com/stringbean) Michael Stringer
- [@tanis2000](https://github.com/tanis2000) Valerio Santinelli
