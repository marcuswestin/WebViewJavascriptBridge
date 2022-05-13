WebViewJavascriptBridge
=======================

An iOS/OSX bridge for sending messages between Obj-C and JavaScript in WKWebViews. Also easy to get js console.log.

More simple more light.  Refactor WebViewJavascriptBridge with AOP
==========================

How to use ?
==========================

### Installation with CocoaPods
Add this to your [podfile](https://guides.cocoapods.org/using/getting-started.html) and run `pod install` to install:

```ruby
pod 'SKJavaScriptBridge', '~> 1.0.3'
```
If you can't find the last version, maybe you need to update local pod repo.
```ruby
pod repo update
```

### Manual installation
Drag the `WebViewJavascriptBridge` folder into your project.

In the dialog that appears, uncheck "Copy items into destination group's folder" and select "Create groups for any folders".

Usage
-----
1) Import the header file and declare an ivar property:

```objc
#import "WebViewJavascriptBridge.h"
```
```objc
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WebViewJavascriptBridge* bridge;
```

```objc
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    if(!_bridge){
              _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView
              showJSconsole:YES
              enableLogging:YES];
       }
```

2) Register a handler in ObjC, and call a JS handler:

```objc
[_bridge registerHandler:@"ObjC Echo" handler:^(id data, WVJBResponseCallback responseCallback) {
	NSLog(@"ObjC Echo called with: %@", data);
	responseCallback(data);
}];
[_bridge callHandler:@"JS Echo" data:nil responseCallback:^(id responseData) {
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

### 如果你有疑问.
你可以观看中文版的视频介绍:https://www.youtube.com/watch?v=ocyKSpMT7tM   
当然你也可以邮件联系我:housenkui@gmail.com 
