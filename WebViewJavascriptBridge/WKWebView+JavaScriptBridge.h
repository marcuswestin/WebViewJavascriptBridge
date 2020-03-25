//
//  WKWebView+JavaScriptBridge.h
//  WKWebView+Console
//
//  Created by 侯森魁 on 2019/10/3.
//  Copyright © 2019 housenkui. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "Logginglevel.h"
NS_ASSUME_NONNULL_BEGIN

typedef NSDictionary WVJBMessage;
typedef void (^WVJBResponseCallback)(id responseData);
typedef void (^WVJBHandler)(id data, WVJBResponseCallback responseCallback);

@interface WKWebView (JavaScriptBridge)<WKScriptMessageHandler>
@property (strong, nonatomic) NSMutableDictionary* responseCallbacks;
@property (strong, nonatomic) NSMutableDictionary* messageHandlers;
@property (strong, nonatomic) WVJBHandler messageHandler;

- (void)registerHandler:(NSString *) handlerName handler:(WVJBHandler)handler;
- (void)removeHandler:(NSString *) handlerName;
- (void)callHandler:(NSString *) handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
+ (void)enableLogging:(Logginglevel)logginglevel;
@end

NS_ASSUME_NONNULL_END
