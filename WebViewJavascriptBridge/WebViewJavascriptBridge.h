//
//  WebViewJavascriptBridge.h
//  ExampleApp-iOS
//
//  Created by ryan on 14/12/2016.
//  Copyright © 2016 Marcus Westin. All rights reserved.
//

#ifndef WEBVIEW_JAVASCRIPT_BRIDGE_H
#define WEBVIEW_JAVASCRIPT_BRIDGE_H

#if __has_include(<WebViewJavascriptBridge/WebViewJavascriptBridge.h>)

#import <WebViewJavascriptBridge/WebViewJavascriptBridgeProtocol.h>
#import <WebViewJavascriptBridge/_WebViewJavascriptBridge.h>
#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>
#import <WebViewJavascriptBridge/WebViewJavascriptBridgeBase.h>

#else

#import "WebViewJavascriptBridgeProtocol.h"
#import "_WebViewJavascriptBridge.h"
#import "WKWebViewJavascriptBridge.h"
#import "WebViewJavascriptBridgeBase.h"


#endif /* __has_include(<WebViewJavascriptBridge/WebViewJavascriptBridge.h>) */

#endif /* WEBVIEW_JAVASCRIPT_BRIDGE_H */
