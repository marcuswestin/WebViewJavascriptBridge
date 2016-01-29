WebViewJavascriptBridge
=======================

[![Build Status](https://travis-ci.org/marcuswestin/WebViewJavascriptBridge.svg)](https://travis-ci.org/marcuswestin/WebViewJavascriptBridge)

An iOS/OSX bridge for sending messages between Obj-C and JavaScript in UIWebViews/WebViews.

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

Installation (iOS & OSX)
------------------------

### Installation with CocoaPods
Add this to your [podfile](https://guides.cocoapods.org/using/getting-started.html) and run `pod install` to install:

```ruby
`pod 'WebViewJavascriptBridge', '~> 4.1.4'`
```

### Manual installation

Drag the `WebViewJavascriptBridge` folder into your project.

In the dialog that appears, uncheck "Copy items into destination group's folder" and select "Create groups for any folders".

Examples
--------

See the `Example Apps/` folder. Open either the iOS or OSX project and hit run to see it in action.

To use a WebViewJavascriptBridge in your own project:

Usage
-----

1) Import the header file and declare an ivar property:

```objc
#import "WebViewJavascriptBridge.h"
```

...

```objc
@property WebViewJavascriptBridge* bridge;
```

2) Instantiate WebViewJavascriptBridge with a UIWebView (iOS) or WebView (OSX):

```objc
self.bridge = [WebViewJavascriptBridge bridgeForWebView:webView handler:^(id data, WVJBResponseCallback responseCallback) {
	NSLog(@"Received message from javascript: %@", data);
	responseCallback(@"Right back atcha");
}];
```

3) Go ahead and send some messages from ObjC to javascript:

```objc
[self.bridge registerHandler:@"ObjC Echo" handler:^(id data, WVJBResponseCallback responseCallback) {
	NSLog(@"ObjC Echo called with: %@", data);
	responseCallback(data);
}];
[self.bridge callHandler:@"JS Echo" responseCallback:^(id responseData) {
	NSLog(@"ObjC received response: %@", responseData);
}];
```

4) Finally, set up the javascript side:
	
```javascript
function setupWebViewJavascriptBridge(callback) {
	if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }
	if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
	window.WVJBCallbacks = [callback];
	var WVJBIframe = document.createElement('iframe');
	WVJBIframe.style.display = 'none';
	WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';
	document.documentElement.appendChild(WVJBIframe);
	setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
}

setupWebViewJavascriptBridge(function(bridge) {
	
	/* Initialize your app here */

	bridge.registerHandler('JS Echo', function(data, responseCallback) {
		console.log("JS Echo called with:", data)
		responseCallback(data)
	})
	bridge.callHandler('ObjC Echo', function responseCallback(responseData) {
		console.log("JS received response:", responseData)
	})
})
```

WKWebView Support (iOS 8+ & OS 10.10+)
--------------------------------------

WARNING: WKWebView still has [many bugs and missing network APIs.](https://github.com/ShingoFukuyama/WKWebViewTips/blob/master/README.md) It may not be a simple drop-in replacement.


WebViewJavascriptBridge supports [WKWebView](http://nshipster.com/wkwebkit/) for iOS 8 and OSX Yosemite. In order to use WKWebView you need to instantiate the `WKWebViewJavascriptBridge`. The rest of the `WKWebViewJavascriptBridge` API is the same as `WebViewJavascriptBridge`.

1) Import the header file:

```objc
#import "WKWebViewJavascriptBridge.h"
```

2) Instantiate WKWebViewJavascriptBridge and with a WKWebView object

```objc
WKWebViewJavascriptBridge* bridge = [WKWebViewJavascriptBridge bridgeForWebView:webView];
```

Contributors & Forks
--------------------
Contributors: https://github.com/marcuswestin/WebViewJavascriptBridge/graphs/contributors

Forks: https://github.com/marcuswestin/WebViewJavascriptBridge/network/members

API Reference
-------------

### ObjC API

##### `[WebViewJavascriptBridge bridgeForWebView:(UIWebView/WebView*)webview`

Create a javascript bridge for the given web view.

Example:

```objc	
[WebViewJavascriptBridge bridgeForWebView:webView];
```

##### `[bridge registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler]`

Register a handler called `handlerName`. The javascript can then call this handler with `WebViewJavascriptBridge.callHandler("handlerName")`.

Example:

```objc
[self.bridge registerHandler:@"getScreenHeight" handler:^(id data, WVJBResponseCallback responseCallback) {
	responseCallback([NSNumber numberWithInt:[UIScreen mainScreen].bounds.size.height]);
}];
[self.bridge registerHandler:@"log" handler:^(id data, WVJBResponseCallback responseCallback) {
	NSLog(@"Log: %@", data);
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

#### `[bridge setWebViewDelegate:UIWebViewDelegate*)webViewDelegate]`

Optionally, set a `UIWebViewDelegate` if you need to respond to the [web view's lifecycle events](http://developer.apple.com/library/ios/documentation/uikit/reference/UIWebViewDelegate_Protocol/Reference/Reference.html).




### Javascript API

##### `bridge.registerHandler("handlerName", function(responseData) { ... })`

Register a handler called `handlerName`. The ObjC can then call this handler with `[bridge callHandler:"handlerName" data:@"Foo"]` and `[bridge callHandler:"handlerName" data:@"Foo" responseCallback:^(id responseData) { ... }]`

Example:

```javascript
bridge.registerHandler("showAlert", function(data) { alert(data) })
bridge.registerHandler("getCurrentPageUrl", function(data, responseCallback) {
	responseCallback(document.location.toString())
})
```


##### `bridge.callHander("handlerName", data, function responseCallback(responseData) { ... })`

Call an ObjC handler called `handlerName`. If `responseCallback` is defined, the ObjC handler can respond.

Example:

```javascript
bridge.callHandler("Log", "Foo")
bridge.callHandler("getScreenHeight", null, function(response) {
	alert('Screen height:' + response)
})
```

iOS4 support (with JSONKit)
---------------------------

*Note*: iOS4 support has not yet been tested in v2+.

WebViewJavascriptBridge uses `NSJSONSerialization` by default. If you need iOS 4 support then you can use [JSONKit](https://github.com/johnezang/JSONKit/), and add `USE_JSONKIT` to the preprocessor macros for your project.
