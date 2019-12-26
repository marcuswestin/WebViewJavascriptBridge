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
pod 'SKJavaScriptBridge', '~> 1.0.1'
```
If native want to get console.log in WKWebView just  ```[WKWebView enableLogging:LogginglevelAll];``` is enough.

### Manual installation

On Native side:
 ![shell文件](https://upload-images.jianshu.io/upload_images/1485140-039a71e6e602bf15.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

On JavaScript side:
 ![shell文件](https://upload-images.jianshu.io/upload_images/1485140-c759d9499766b8b9.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/1080/format/webp)
 
 In fact,just one ```console.log('callNative')``` is enough to call native method.I had hack the Javascript method ```console.log```.
 Any question you can  contact me with:housenkui@gmail.com or WeChat :housenkui
