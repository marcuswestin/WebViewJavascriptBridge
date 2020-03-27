WebViewJavascriptBridge
=======================

An iOS/OSX bridge for sending messages between Obj-C and JavaScript in WKWebViews.

More simple more light.  Refactor WebViewJavascriptBridge with AOP
==========================

How to use ?
==========================

### Installation with CocoaPods
Add this to your [podfile](https://guides.cocoapods.org/using/getting-started.html) and run `pod install` to install:

```ruby
pod 'SKJavaScriptBridge'
```
If native want to get console.log in WKWebView just  ```[WKWebView enableLogging:LogginglevelAll];``` is enough.

### Manual installation
Drag the `WebViewJavascriptBridge` folder into your project.

In the dialog that appears, uncheck "Copy items into destination group's folder" and select "Create groups for any folders".

Usage
-----
1) Import the header file and declare an ivar property:

```objc
#import "WKWebView+JavaScriptBridge.h"
```
```objc
@property (nonatomic, strong) WKWebView *webView;
```

```objc
- (WKWebView *) webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        [self.view addSubview:_webView];
        //If you set LogginglevelAll ,Xcode command Line will show all JavaScript console.log.
        [WKWebView enableLogging:LogginglevelAll];
    }
    return _webView;
}
```

2) Register a handler in ObjC, and call a JS handler:

```objc
[self.webView registerHandler:@"ObjC Echo" handler:^(id data, WVJBResponseCallback responseCallback) {
	NSLog(@"ObjC Echo called with: %@", data);
	responseCallback(data);
}];
[self.webView callHandler:@"JS Echo" data:nil responseCallback:^(id responseData) {
	NSLog(@"ObjC received response: %@", responseData);
}];
```
3) Copy and paste `setupWebViewJavascriptBridge` into your JS:
	
```javascript
function setupWebViewJavascriptBridge(callback) {
	 return callback(WebViewJavascriptBridge); 
}
```
5) Finally, call `setupWebViewJavascriptBridge` and then use the bridge to register handlers and call ObjC handlers:

```javascript
setupWebViewJavascriptBridge(function(bridge) {
	
	/* Initialize your app here */

	bridge.registerHandler('JS Echo', function(data, responseCallback) {
		console.log("JS Echo called with:", data)
		responseCallback(data)
	})
	bridge.callHandler('ObjC Echo', {'key':'value'}, function responseCallback(responseData) {
		console.log("JS received response:", responseData)
	})
})
```
### Any question.
You can watch this chinese video https://www.youtube.com/watch?v=4JUNQkohh5E.  
English video https://www.youtube.com/watch?v=POohaYA-ew0.  
Also you can contact me with:housenkui@gmail.com or WeChat :[housenkui](https://github.com/housenkui/)
