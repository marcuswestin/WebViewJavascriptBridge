WebViewJavascriptBridge
=======================

An iOS/OSX bridge for sending messages between Obj-C and JavaScript in UIWebViews/WebViews.

If you like WebViewJavascriptBridge you may also want to check out [WebViewProxy](https://github.com/marcuswestin/WebViewProxy).

In the Wild
-----------
WebViewJavascriptBridge is used by a range of companies and projects. This list is incomplete, but feel free to add your's and send a PR.

- [Facebook Messenger](https://www.facebook.com/mobile/messenger)
- [Facebook Paper](https://facebook.com/paper)
- [Yardsale](https://www.getyardsale.com/)
- [EverTrue](http://www.evertrue.com/)
- [Game Insight](http://www.game-insight.com/)
- [Altralogica](http://www.altralogica.it)
- [Sush.io](http://www.sush.io)
- Flutterby Labs
- JD Media's [鼎盛中华](https://itunes.apple.com/us/app/ding-sheng-zhong-hua/id537273940?mt=8)
- Dojo4's [Imbed](http://imbed.github.io/)
- [CareZone](https://carezone.com)
- [Hemlig](http://www.hemlig.co)
- [FRIL](https://fril.jp)

Setup & Examples (iOS & OSX)
----------------------------

Start with the Example Apps/ folder. Open either the iOS or OSX project and hit run to see it in action.

To use a WebViewJavascriptBridge in your own project:

1) Drag the `WebViewJavascriptBridge` folder into your project.

  - In the dialog that appears, uncheck "Copy items into destination group's folder" and select "Create groups for any folders"
  
2) Import the header file and declare an ivar property:

```objc
#import "WebViewJavascriptBridge.h"
```

...

```objc
@property WebViewJavascriptBridge* bridge;
```

3) Instantiate WebViewJavascriptBridge with a UIWebView (iOS) or WebView (OSX):

```objc
self.bridge = [WebViewJavascriptBridge bridgeForWebView:webView handler:^(id data, WVJBResponseCallback responseCallback) {
	NSLog(@"Received message from javascript: %@", data);
	responseCallback(@"Right back atcha");
}];
```

4) Go ahead and send some messages from ObjC to javascript:

```objc
[self.bridge send:@"Well hello there"];
[self.bridge send:[NSDictionary dictionaryWithObject:@"Foo" forKey:@"Bar"]];
[self.bridge send:@"Give me a response, will you?" responseCallback:^(id responseData) {
	NSLog(@"ObjC got its response! %@", responseData);
}];
```

4) Finally, set up the javascript side:
	
```javascript
function connectWebViewJavascriptBridge(callback) {
	if (window.WebViewJavascriptBridge) {
		callback(WebViewJavascriptBridge)
	} else {
		document.addEventListener('WebViewJavascriptBridgeReady', function() {
			callback(WebViewJavascriptBridge)
		}, false)
	}
}

connectWebViewJavascriptBridge(function(bridge) {
	
	/* Init your app here */

	bridge.init(function(message, responseCallback) {
		alert('Received message: ' + message)   
		if (responseCallback) {
			responseCallback("Right back atcha")
		}
	})
	bridge.send('Hello from the javascript')
	bridge.send('Please respond to this', function responseCallback(responseData) {
		console.log("Javascript got its response", responseData)
	})
})
```

WKWebView Support (iOS 8 & OS 10.10)
------------------------------------

WARNING: WKWebView still has [many bugs and missing network APIs.](https://github.com/ShingoFukuyama/WKWebViewTips/blob/master/README.md) It may not be a simple drop-in replacement.


WebViewJavascriptBridge supports [WKWebView](http://nshipster.com/wkwebkit/) for iOS 8 and OSX Yosemite. In order to use WKWebView you need to instantiate the `WKWebViewJavascriptBridge`. The rest of the `WKWebViewJavascriptBridge` API is the same as `WebViewJavascriptBridge`.

1) Import the header file:

```objc
#import "WKWebViewJavascriptBridge.h"
```

2) Instantiate WKWebViewJavascriptBridge and with a WKWebView object

```objc
WKWebViewJavascriptBridge* bridge = [WKWebViewJavascriptBridge bridgeForWebView:webView handler:^(id data, WVJBResponseCallback responseCallback) {
	NSLog(@"Received message from javascript: %@", data);
	responseCallback(@"Right back atcha");
}];
```

Contributors & Forks
--------------------
Contributors: https://github.com/marcuswestin/WebViewJavascriptBridge/graphs/contributors

Forks: https://github.com/marcuswestin/WebViewJavascriptBridge/network/members

API Reference
-------------

### ObjC API

##### `[WebViewJavascriptBridge bridgeForWebView:(UIWebView/WebView*)webview handler:(WVJBHandler)handler]`
##### `[WebViewJavascriptBridge bridgeForWebView:(UIWebView/WebView*)webview webViewDelegate:(UIWebViewDelegate*)webViewDelegate handler:(WVJBHandler)handler]`

Create a javascript bridge for the given web view.

The `WVJBResponseCallback` will not be `nil` if the javascript expects a response.

Optionally, pass in `webViewDelegate:(UIWebViewDelegate*)webViewDelegate` if you need to respond to the [web view's lifecycle events](http://developer.apple.com/library/ios/documentation/uikit/reference/UIWebViewDelegate_Protocol/Reference/Reference.html).

Example:

```objc	
[WebViewJavascriptBridge bridgeForWebView:webView handler:^(id data, WVJBResponseCallback responseCallback) {
	NSLog(@"Received message from javascript: %@", data);
	if (responseCallback) {
		responseCallback(@"Right back atcha");
	}
}]

[WebViewJavascriptBridge bridgeForWebView:webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) { /* ... */ }];
```

##### `[bridge send:(id)data]`
##### `[bridge send:(id)data responseCallback:(WVJBResponseCallback)responseCallback]`

Send a message to javascript. Optionally expect a response by giving a `responseCallback` block.

Example:

```objc
[self.bridge send:@"Hi"];
[self.bridge send:[NSDictionary dictionaryWithObject:@"Foo" forKey:@"Bar"]];
[self.bridge send:@"I expect a response!" responseCallback:^(id responseData) {
	NSLog(@"Got response! %@", responseData);
}];
```

##### `[bridge registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler]`

Register a handler called `handlerName`. The javascript can then call this handler with `WebViewJavascriptBridge.callHandler("handlerName")`.

Example:

```objc
[self.bridge registerHandler:@"getScreenHeight" handler:^(id data, WVJBResponseCallback responseCallback) {
	responseCallback([NSNumber numberWithInt:[UIScreen mainScreen].bounds.size.height]);
}];
```

##### `[bridge callHandler:(NSString*)handlerName data:(id)data]`
##### `[bridge callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)callback]`

Call the javascript handler called `handlerName`. Optionally expect a response by giving a `responseCallback` block.

Example:

```objc
[self.bridge callHandler:@"showAlert" data:@"Hi from ObjC to JS!"];
[self.bridge callHandler:@"getCurrentPageUrl" data:nil responseCallback:^(id responseData) {
	NSLog(@"Current UIWebView page URL is: %@", responseData);
}];
```

#### Custom bundle
`WebViewJavascriptBridge` requires `WebViewJavascriptBridge.js.txt` file that is injected into web view to create a bridge on JS side. Standard implementation uses `mainBundle` to search for this file. If you e.g. build a static library and you have that file placed somewhere else you can use this method to specify which bundle should be searched for `WebViewJavascriptBridge.js.txt` file:

##### `[WebViewJavascriptBridge bridgeForWebView:(UIWebView/WebView*)webView webViewDelegate:(UIWebViewDelegate*)webViewDelegate handler:(WVJBHandler)handler resourceBundle:(NSBundle*)bundle`

Example:

```objc
[WebViewJavascriptBridge bridgeForWebView:_webView
                          webViewDelegate:self
                                  handler:^(id data, WVJBResponseCallback responseCallback) {
                                      NSLog(@"Received message from javascript: %@", data);
                                  }
                           resourceBundle:[NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"ResourcesBundle" withExtension:@"bundle"]]
];
```

### Javascript API

##### `document.addEventListener('WebViewJavascriptBridgeReady', function onBridgeReady(event) { ... }, false)`

Always wait for the `WebViewJavascriptBridgeReady` DOM event.

Example:

```javascript
document.addEventListener('WebViewJavascriptBridgeReady', function(event) {
	var bridge = event.bridge
	// Start using the bridge
}, false)
```

##### `bridge.init(function messageHandler(data, response) { ... })`

Initialize the bridge. This should be called inside of the `'WebViewJavascriptBridgeReady'` event handler.

The `messageHandler` function will receive all messages sent from ObjC via `[bridge send:(id)data]` and `[bridge send:(id)data responseCallback:(WVJBResponseCallback)responseCallback]`.

The `response` object will be defined if if ObjC sent the message with a `WVJBResponseCallback` block.

Example:

```javascript
bridge.init(function(data, responseCallback) {
	alert("Got data " + JSON.stringify(data))
	if (responseCallback) {
		responseCallback("Right back atcha!")
	}
})
```

##### `bridge.send("Hi there!")`
##### `bridge.send({ Foo:"Bar" })`
##### `bridge.send(data, function responseCallback(responseData) { ... })`

Send a message to ObjC. Optionally expect a response by giving a `responseCallback` function.

Example:

```javascript
bridge.send("Hi there!")
bridge.send("Hi there!", function(responseData) {
	alert("I got a response! "+JSON.stringify(responseData))
})
```

##### `bridge.registerHandler("handlerName", function(responseData) { ... })`

Register a handler called `handlerName`. The ObjC can then call this handler with `[bridge callHandler:"handlerName" data:@"Foo"]` and `[bridge callHandler:"handlerName" data:@"Foo" responseCallback:^(id responseData) { ... }]`

Example:

```javascript
bridge.registerHandler("showAlert", function(data) { alert(data) })
bridge.registerHandler("getCurrentPageUrl", function(data, responseCallback) {
	responseCallback(document.location.toString())
})
```

iOS4 support (with JSONKit)
---------------------------

*Note*: iOS4 support has not yet been tested in v2+.

WebViewJavascriptBridge uses `NSJSONSerialization` by default. If you need iOS 4 support then you can use [JSONKit](https://github.com/johnezang/JSONKit/), and add `USE_JSONKIT` to the preprocessor macros for your project.
