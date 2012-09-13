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
	[javascriptBridge send:@"Give me a response, will you?" responseCallback:^(id responseData) {
		NSLog(@"I got a response! %@", responseData);
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

iOS4 support (with JSONKit)
---------------------------

*Note*: iOS4 support has not yet been tested in v2.

WebViewJavascriptBridge uses `NSJSONSerialization` by default. If you need iOS 4 support then you can use [JSONKit](https://github.com/johnezang/JSONKit/), and add `USE_JSONKIT` to the preprocessor macros for your project.

API Reference
-------------

### ObjC

##### `[WebViewJavascriptBridge javascriptBridgeForWebView:(UIWebView*)webview handler:(WVJBHandler)handler]`

Create a javascript bridge for the given UIWebView.

Example:
	
	[WebViewJavascriptBridge javascriptBridgeForWebView:webView handler:^(id data, WVJBCallback responseCallback) {
		NSLog(@"Received message from javascript: %@", data);
		if (responseCallback) {
			responseCallback(@"Right back atcha")
		}
	}]

The handler's `responseCallback` will be a block if javascript sent the message with a function responseCallback, or `nil` otherwise.

##### `[bridge send:(id)data]`
##### `[bridge send:(id)data responseCallback:(WVJBResponseCallback)responseCallback]`

Send a message to javascript. Optionally expect a response by giving a `responseCallback` block.

Example:

	[bridge send:@"Hi"];
	[bridge send:[NSDictionary dictionaryWithObject:@"Foo" forKey:@"Bar"]];
	[bridge send:@"I expect a response!" responseCallback:^(id data) {
		NSLog(@"Got response: %@", data);
	}];

##### `[bridge registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler]`

Register a handler called `handlerName`. The javascript can then call this handler with `WebViewJavascriptBridge.callHandler("handlerName", function(response) { ... })`.

Example:

	[bridge registerHandler:@"getScreenHeight" handler:^(id data, WVJBResponseCallback responseCallback) {
		responseCallback([NSNumber numberWithInt:[UIScreen mainScreen].bounds.size.height]);
	}];

##### `[bridge callHandler:(NSString*)handlerName data:(id)data]`
##### `[bridge callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)callback]`

Call the javascript handler called `handlerName`. Optionally expect a response by giving a `responseCallback` block.

Example:

	[bridge callHandler:@"showAlert" data:@"Hi from ObjC to JS!"];
	[bridge callHandler:@"getCurrentPageUrl" data:nil responseCallback:^(id responseData) {
		NSLog(@"Current UIWebView page URL is: %@", responseData);
	}];


### Javascript

##### `document.addEventListener('WebViewJavascriptBridgeReady', function onBridgeReadyHandler() { ... }, false)`

Always wait for the `WebViewJavascriptBridgeReady` DOM event before using `WebViewJavascriptBridge`.

Example:

	document.addEventListener('WebViewJavascriptBridgeReady', function() {
		// Start using WebViewJavascriptBridge
	}, false)

##### `WebViewJavascriptBridge.init(function messageHandler(data, responseCallback) { ... })`

Initialize the WebViewJavascriptBridge. This should be called inside of the `'WebViewJavascriptBridgeReady'` event handler.

The `messageHandler` function will receive all messages sent from ObjC via `[bridge send:(id)data]` and `[bridge send:(id)data responseCallback:(WVJBResponseCallback)responseCallback]`.

The `responseCallback` will be a function if ObjC sent the message with a `WVJBResponseCallback` block, or `undefined` otherwise.

Example:

	WebViewJavascriptBridge.init(function(data, responseCallback) {
		alert("Got data " + JSON.stringify(data))
		if (responseCallback) {
			responseCallback("Right back atcha!")
		}
	})

##### `WebViewJavascriptBridge.send("Hi there!")`
##### `WebViewJavascriptBridge.send({ Foo:"Bar" })`
##### `WebViewJavascriptBridge.send(data, function responseCallback(responseData) { ... })`

Send a message to ObjC. Optionally expect a response by giving a `responseCallback` function.

Example:

	WebViewJavascriptBridge.send("Hi there!")
	WebViewJavascriptBridge.send("Hi there!", function(response) {
		alert("I got a response! "+JSON.stringify(response))
	})

##### `WebViewJavascriptBridge.registerHandler("handlerName", function(data, responseCallback) { ... })`

Register a handler called `handlerName`. The ObjC can then call this handler with `[bridge callHandler:"handlerName" data:@"Foo"]` and `[bridge callHandler:"handlerName" data:@"Foo" responseCallback:^(id responseData) { ... }]`

Example:

	WebViewJavascriptBridge.registerHandler("showAlert", function(data) { alert(data) })
	WebViewJavascriptBridge.registerHandler("getCurrentPageUrl", function(data, responseCallback) {
		responseCallback(document.location.toString())
	})

Contributors
------------

- [@marcuswestin](https://github.com/marcuswestin) Marcus Westin
- [@psineur](https://github.com/psineur) Stepan Generalov
- [@sergiocampama](https://github.com/sergiocampama) Sergio Campamá
- [@stringbean](https://github.com/stringbean) Michael Stringer
- [@tanis2000](https://github.com/tanis2000) Valerio Santinelli
