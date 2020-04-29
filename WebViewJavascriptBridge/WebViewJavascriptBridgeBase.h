//
//  WebViewJavascriptBridgeBase.h
//  TestPod
//
//  Created by 侯森魁 on 2020/4/29.
//  Copyright © 2020 侯森魁. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol WebViewJavascriptBridgeBaseDelegate <NSObject>
- (NSString*) _evaluateJavascript:(NSString*)javascriptCommand;
@end
typedef NSDictionary WVJBMessage;
typedef void (^WVJBResponseCallback)(id responseData);
typedef void (^WVJBHandler)(id data, WVJBResponseCallback responseCallback);

@interface WebViewJavascriptBridgeBase : NSObject
@property (weak, nonatomic) id <WebViewJavascriptBridgeBaseDelegate> delegate;
@property (strong, nonatomic) NSMutableDictionary* responseCallbacks;
@property (strong, nonatomic) NSMutableDictionary* messageHandlers;
@property (strong, nonatomic) WVJBHandler messageHandler;

- (void)sendData:(id)data responseCallback:(WVJBResponseCallback)responseCallback handlerName:(NSString*)handlerName;
- (void)flushMessageQueue:(NSString *)messageQueueString;
@end

NS_ASSUME_NONNULL_END
