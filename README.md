WebViewJavascriptBridge
=======================

An iOS bridge for sending messages to and from javascript in a UIWebView.

Setup & Examples
----------------

Just open the Xcode project and hit run to see ExampleApp run.

To use a WebViewJavascriptBridge in your own project:

1) Drag the `WebViewJavascriptBridge` folder into your project.

  - In the dialog that appears, uncheck "Copy items into destination group's folder" and select "Create groups for any folders"

2) Import the header file:

	#import "WebViewJavascriptBridge.h"

3) Instantiate a UIWebView and a WebViewJavascriptBridge:

	UIWebView* webView = [[UIWebView alloc] initWithFrame:self.window.bounds];
	WebViewJavascriptBridge* javascriptBridge = [WebViewJavascriptBridge javascriptBridgeForWebView:webView handler:^(id data, WVJBResponseCallback callback) {
		NSLog(@"Received message from javascript: %@", data);
	}];

4) Go ahead and send some messages from ObjC to javascript:

	[javascriptBridge send:@"Well hello there"];
	[javascriptBridge send:[NSDictionary dictionaryWithObject:@"Foo" forKey:@"Bar"]];
	[javascriptBridge send:@"Give me a response, will you?" responseCallback:^(id responseData) {
		NSLog(@"I got a response! %@", responseData);
	}];

4) Finally, set up the javascript side:
	
	document.addEventListener('WebViewJavascriptBridgeReady', function onBridgeReady(event) {
		var bridge = event.bridge
		bridge.init(function(message, responseCallback) {
			alert('Received message: ' + message)   
			if (responseCallback) {
				responseCallback("Right back atcha")
			}
		})
		bridge.send('Hello from the javascript')
	}, false)

API Reference
-------------

### ObjC

##### `[WebViewJavascriptBridge javascriptBridgeForWebView:(UIWebView*)webview handler:(WVJBHandler)handler]`
##### `[WebViewJavascriptBridge javascriptBridgeForWebView:(UIWebView*)webview webViewDelegate:(UIWebViewDelegate*)webViewDelegate handler:(WVJBHandler)handler]`

Create a javascript bridge for the given UIWebView.

Example:
	
	[WebViewJavascriptBridge javascriptBridgeForWebView:webView handler:^(id data, WVJBResponseCallback responseCallback) {
		NSLog(@"Received message from javascript: %@", data);
		if (responseCallback) {
			responseCallback(@"Right back atcha")
		}
	}]
	
	[WebViewJavascriptBridge javascriptBridgeForWebView:webView webViewDelegate:self handler:^(id data, WVJBCallback responseCallback) { /* ... */ }];

The handler's `responseCallback` will be a block if javascript sent the message with a function responseCallback, or `nil` otherwise.

Optionally, pass in `webViewDelegate:(UIWebViewDelegate*)webViewDelegate` if you need to respond to the [UIWebView's lifecycle events](http://developer.apple.com/library/ios/documentation/uikit/reference/UIWebViewDelegate_Protocol/Reference/Reference.html).


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

##### `document.addEventListener('WebViewJavascriptBridgeReady', function onBridgeReady(bridge) { ... }, false)`

Always wait for the `WebViewJavascriptBridgeReady` DOM event.

Example:

	document.addEventListener('WebViewJavascriptBridgeReady', function(bridge) {
		// Start using the bridge
	}, false)

##### `bridge.init(function messageHandler(data, responseCallback) { ... })`

Initialize the bridge. This should be called inside of the `'WebViewJavascriptBridgeReady'` event handler.

The `messageHandler` function will receive all messages sent from ObjC via `[bridge send:(id)data]` and `[bridge send:(id)data responseCallback:(WVJBResponseCallback)responseCallback]`.

The `responseCallback` will be a function if ObjC sent the message with a `WVJBResponseCallback` block, or `undefined` otherwise.

Example:

	bridge.init(function(data, responseCallback) {
		alert("Got data " + JSON.stringify(data))
		if (responseCallback) {
			responseCallback("Right back atcha!")
		}
	})

##### `bridge.send("Hi there!")`
##### `bridge.send({ Foo:"Bar" })`
##### `bridge.send(data, function responseCallback(responseData) { ... })`

Send a message to ObjC. Optionally expect a response by giving a `responseCallback` function.

Example:

	bridge.send("Hi there!")
	bridge.send("Hi there!", function(response) {
		alert("I got a response! "+JSON.stringify(response))
	})

##### `WebViewJavascrbridgeiptBridge.registerHandler("handlerName", function(data, responseCallback) { ... })`

Register a handler called `handlerName`. The ObjC can then call this handler with `[bridge callHandler:"handlerName" data:@"Foo"]` and `[bridge callHandler:"handlerName" data:@"Foo" responseCallback:^(id responseData) { ... }]`

Example:

	bridge.registerHandler("showAlert", function(data) { alert(data) })
	bridge.registerHandler("getCurrentPageUrl", function(data, responseCallback) {
		responseCallback(document.location.toString())
	})


iOS4 support (with JSONKit)
---------------------------

*Note*: iOS4 support has not yet been tested in v2.

WebViewJavascriptBridge uses `NSJSONSerialization` by default. If you need iOS 4 support then you can use [JSONKit](https://github.com/johnezang/JSONKit/), and add `USE_JSONKIT` to the preprocessor macros for your project.


Contributors
------------

- [@marcuswestin](https://github.com/marcuswestin) Marcus Westin
- [@psineur](https://github.com/psineur) Stepan Generalov
- [@sergiocampama](https://github.com/sergiocampama) Sergio Campamá
- [@stringbean](https://github.com/stringbean) Michael Stringer
- [@tanis2000](https://github.com/tanis2000) Valerio Santinelli
- [@drewburch](https://github.com/drewburch) Andrew Burch
- [@pj4533](https://github.com/pj4533) PJ Gray