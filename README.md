WebViewJavascriptBridge
=======================

An iOS bridge for sending messages to and from javascript in a UIWebView

Getting started
---------------

Just open the Xcode project (requires Xcode > 4.2) and hit run to see the example application work.

Usage
-----

See ExampleAppDelegate.* for example code. To use it in your own project:

1) Copy `WebViewJavascriptBridge/WebViewJavascriptBridge.h` and `WebViewJavascriptBridge/WebViewJavascriptBridge.m` into your Xcode project

2) Instantiate a UIWebView, a WebViewJavascriptBridge, and set yourself as the bridge's delegate

	#import <UIKit/UIKit.h>
	#import "WebViewJavascriptBridge.h"

	@interface ExampleAppDelegate : UIResponder <UIApplicationDelegate, WebViewJavascriptBridgeDelegate>
	
	@end
	
	@implementation ExampleAppDelegate
	
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
	    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		
	    self.webView = [[UIWebView alloc] initWithFrame:self.window.bounds];
	    [self.window addSubview:self.webView];
	    self.javascriptBridge = [WebViewJavascriptBridge javascriptBridgeWithDelegate:self];
	    self.webView.delegate = self.javascriptBridge;
		
	    [self.window makeKeyAndVisible];
	    return YES;
	}

	- (void)javascriptBridge:(WebViewJavascriptBridge *)bridge receivedMessage:(NSString *)message fromWebView:(UIWebView *)webView 
	{
	    NSLog(@"MyJavascriptBridgeDelegate received message: %@", message);
	}

	@end

3) Go ahead and send some messages from Objc to javascript

	[self.javascriptBridge sendMessage:@"Well hello there" toWebView:self.webView];

4) Finally, set up the javascript side of things
	
	document.addEventListener('WebViewJavascriptBridgeReady', function onBridgeReady() {
		WebViewJavascriptBridge.setMessageHandler(function(message) {
			alert('Received message: ' + message)
		})
		WebViewJavascriptBridge.sendMessage('Hello from the javascript')
	}, false)

### Registering callbacks

The JS to ObjC and ObjC to JS callbacks use `NSJSONSerialization` to convert to/from JSON. If you need iOS 4 support then you can use [JSONKit](https://github.com/johnezang/JSONKit/) by adding `USE_JSONKIT` to the preprocessor macros for your project (you will need to include JSONKit in your project).

#### JS to ObjC

You can register Objective-C blocks and call them from Javascript. In Objective-C register a block with the bridge:

    [self.javascriptBridge registerObjcCallback:@"testObjcCallback" withCallback:^(NSDictionary *params){
        NSLog(@"ObjC callback [testObjcCallback] called with params: %@", params);
    }];

Then call from Javascript using:

    WebViewJavascriptBridge.callObjcCallback('testObjcCallback', { 'foo': 'bar' });

This will result in the following being logged:

    ObjC callback [testObjcCallback] called with params: { 'foo' = 'bar'; }

#### ObjC to JS

You can also register Javascript functions and call them from Objective-C. In Javascript register a function with the bridge:

    WebViewJavascriptBridge.registerJsCallback('testJsCallback', function(params) {
        var el = document.body.appendChild(document.createElement('div'));
        el.innerHTML = 'JS [testJsCallback] called with params: ' + JSON.stringify(params);
    });

Then call from Objective-C using:

    [self.javascriptBridge callJavascriptCallback:@"testJsCallback"
                                       withParams:[NSDictionary dictionaryWithObjectsAndKeys:@"bar", @"foo", nil]
                                        toWebView:self.webView];

This will result in a div with the following getting added to the HTML:

    JS [testJsCallback] called with params: {"foo":"bar"}

*Note:* You should register any callbacks before you call `WebViewJavascriptBridge.setMessageHandler` otherwise any callback calls received before the HTML is fully loaded will be delivered as normal messages.

ARC
---
If you're using ARC in your project, add `-fno-objc-arc` as a compiler flag to the `WebViewJavascriptBridge.m` file.

Contributors
------------

- [@marcuswestin](https://github.com/marcuswestin) Marcus Westin
- [@psineur](https://github.com/psineur) Stepan Generalov
- [@sergiocampama](https://github.com/sergiocampama) Sergio Campamá
- [@stringbean](https://github.com/stringbean) Michael Stringer
