//
//  ExampleAppViewController.h
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 1/13/14.
//  Copyright (c) 2014 Marcus Westin. All rights reserved.
//

#import <UIKit/UIKit.h>


#if defined(__IPHONE_8_0)
    #import <WebKit/WebKit.h>
    #define EXAMPLE_WEBVIEW_TYPE WKWebView
    #define EXAMPLE_WEBVIEW_DELEGATE_TYPE NSObject<WKNavigationDelegate>
    #define EXAMPLE_WEBVIEW_DELEGATE_CONTROLLER UINavigationController<WKNavigationDelegate>
    #define EXAMPLE_BRIDGE_TYPE WKWebViewJavascriptBridge
#else
    #define EXAMPLE_WEBVIEW_TYPE UIWebView
    #define EXAMPLE_WEBVIEW_DELEGATE_TYPE NSObject<UIWebViewDelegate>
    #define EXAMPLE_WEBVIEW_DELEGATE_CONTROLLER UINavigationController<UIWebViewDelegate>
    #define EXAMPLE_BRIDGE_TYPE WebViewJavascriptBridge
#endif


@interface ExampleAppViewController : EXAMPLE_WEBVIEW_DELEGATE_CONTROLLER

@end
