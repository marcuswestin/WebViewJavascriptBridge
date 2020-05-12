//
//  WebViewJavascriptBridge.h
//  TestPod
//
//  Created by 侯森魁 on 2020/4/29.
//  Copyright © 2020 侯森魁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridgeBase.h"
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface WebViewJavascriptBridge : NSObject<WebViewJavascriptBridgeBaseDelegate,WKScriptMessageHandler>

+ (instancetype)bridgeForWebView:(WKWebView*)webView
                   showJSconsole:(BOOL)show
                   enableLogging:(BOOL)enable;
- (void)registerHandler:(NSString*)handlerName handler:(nullable WVJBHandler)handler;
- (void)removeHandler:( NSString* )handlerName;
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(nullable id)data;
- (void)callHandler:(NSString*)handlerName data:(nullable id)data responseCallback:(nullable  WVJBResponseCallback)responseCallback;
@end

NS_ASSUME_NONNULL_END
