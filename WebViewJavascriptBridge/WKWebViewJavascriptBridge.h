//
//  WKWebViewJavascriptBridge.h
//
//  Created by @LokiMeyburg on 10/15/14.
//  Copyright (c) 2014 @LokiMeyburg. All rights reserved.
//

#if (__MAC_OS_X_VERSION_MAX_ALLOWED > __MAC_10_9 || __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_1)
#define supportsWKWebKit
#endif

#if defined(supportsWKWebKit )

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#import "WebViewJavascriptBridgeBase.h"
#import "WebViewJavascriptBridgeProtocol.h"

@interface WKWebViewJavascriptBridge : NSObject<WKNavigationDelegate, WebViewJavascriptBridgeBaseDelegate, WebViewJavascriptBridgeProtocol>

+ (instancetype)bridgeForWebView:(WKWebView*)webView;
- (void)setWebViewDelegate:(id<WKNavigationDelegate>)webViewDelegate;

@end

#endif
