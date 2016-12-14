//
//  WebViewJavascriptBridgeProtocol.h
//  ExampleApp-iOS
//
//  Created by ryan on 14/12/2016.
//  Copyright © 2016 Marcus Westin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridgeBase.h"

@protocol WebViewJavascriptBridgeProtocol <NSObject>

+ (instancetype)bridgeForWebView:(id)webView;
+ (void)enableLogging;

- (void)registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler;
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
- (void)reset;
- (void)setWebViewDelegate:(id)webViewDelegate;
- (void)disableJavscriptAlertBoxSafetyTimeout;

@end
