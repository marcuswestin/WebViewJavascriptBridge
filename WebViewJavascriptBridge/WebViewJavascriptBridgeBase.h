//
//  WebViewJavascriptBridgeBase.h
//  ExampleApp-iOS
//
//  Created by Loki Meyburg on 2014-10-29.
//  Copyright (c) 2014 Marcus Westin. All rights reserved.
//
#import <Foundation/Foundation.h>

#define kCustomProtocolScheme @"wvjbscheme"
#define kQueueHasMessage      @"__WVJB_QUEUE_MESSAGE__"

typedef void (^WVJBResponseCallback)(id responseData);
typedef void (^WVJBHandler)(id data, WVJBResponseCallback responseCallback);
typedef NSDictionary WVJBMessage;


// setup delegate
@protocol WebViewJavascriptBridgeBaseDelegate <NSObject>
- (void) _evaluateJavascript:(NSString*)javascriptCommand;
@end



@interface WebViewJavascriptBridgeBase : NSObject

// Delegate property
@property (assign) id <WebViewJavascriptBridgeBaseDelegate> delegate;
@property (strong, nonatomic) NSMutableArray* startupMessageQueue;
@property (strong, nonatomic) NSMutableDictionary* responseCallbacks;
@property (strong, nonatomic) NSMutableDictionary* messageHandlers;
@property (strong, nonatomic) WVJBHandler messageHandler;
@property NSUInteger numRequestsLoading;


+ (void)enableLogging;
-(id)initWithWebViewType:(NSString*)webViewType handler:(WVJBHandler)messageHandler resourceBundle:(NSBundle*)bundle;
-(void)reset;
- (void)_sendData:(id)data responseCallback:(WVJBResponseCallback)responseCallback handlerName:(NSString*)handlerName;
- (void)_queueMessage:(WVJBMessage*)message;
- (void)_dispatchMessage:(WVJBMessage*)message;
- (void)_flushMessageQueue:(NSString *)messageQueueString;

// specific extractions
- (void) injectJavascriptFile:(BOOL)shouldInject;
-(BOOL) correctProcotocolScheme:(NSURL*)url;
-(BOOL) correctHost:(NSURL*)urll;
-(void) logUnkownMessage:(NSURL*)url;
-(NSString *) webViewJavascriptCheckCommand;
-(NSString *) webViewJavascriptFetchQueyCommand;


// probably dont need to be public
- (NSString *)_serializeMessage:(id)message;
- (NSArray*)_deserializeMessageJSON:(NSString *)messageJSON;
- (void)_log:(NSString *)action json:(id)json;


@end