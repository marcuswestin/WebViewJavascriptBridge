//
//  WKWebView+JavaScriptBridge.m
//  WKWebView+Console
//
//  Created by 侯森魁 on 2019/10/3.
//  Copyright © 2019 housenkui. All rights reserved.
//

#import "WKWebView+JavaScriptBridge.h"
#import "WKWebViewJavascriptBridge_JS.h"
#import "Tool.h"
#import "Utils.h"
#define kBridgePrefix @"__bridge__"

static long _uniqueId = 0;
static Logginglevel loggingLevel = 0;

@implementation WKWebView (JavaScriptBridge)

+(void)load {
    swizzleMethod([self class], @selector(initWithFrame:configuration:), @selector(initWithJavaScriptBridgeFrame:configuration:));
}
- (instancetype)initWithJavaScriptBridgeFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    if (self = [self initWithJavaScriptBridgeFrame:frame configuration:configuration]) {
        self.messageHandlers = [NSMutableDictionary dictionary];
        self.responseCallbacks = [NSMutableDictionary dictionary];
        
        WKUserContentController *userCC = self.configuration.userContentController;
        [userCC addScriptMessageHandler:self name:@"log"];
        [self _injectJavascriptFile];
    }
    return self;
}

- (void)_injectJavascriptFile {
    NSString *jsCode = _WebViewJavascriptBridge_js();
    //injected the method when H5 starts to create the DOM tree
    [self.configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString * body = (NSString * )message.body;
    if ([self _filterMessage:body]) {
        NSMutableString *mstr = [NSMutableString stringWithString:body];
        [mstr replaceOccurrencesOfString:kBridgePrefix withString:@"" options:0 range:NSMakeRange(0, 10)];
        [self _flushMessageQueue:mstr];
    }
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    self.messageHandlers[handlerName] = handler;
}

- (void)removeHandler:(NSString *)handlerName {
    [self.messageHandlers removeObjectForKey:handlerName];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback {
    [self _sendData:data responseCallback:responseCallback handlerName:handlerName];
}
- (void)_sendData:(id)data responseCallback:(WVJBResponseCallback)responseCallback handlerName:(NSString*)handlerName {
    NSMutableDictionary* message = [NSMutableDictionary dictionary];
    
    if (data) {
        message[@"data"] = data;
    }
    
    if (responseCallback) {
        NSString* callbackId = [NSString stringWithFormat:@"objc_cb_%ld", ++_uniqueId];
        self.responseCallbacks[callbackId] = [responseCallback copy];
        message[@"callbackId"] = callbackId;
    }
    
    if (handlerName) {
        message[@"handlerName"] = handlerName;
    }
    [self _queueMessage:message];
}

- (void)_queueMessage:(WVJBMessage*)message {
    [self _dispatchMessage:message];
}
- (void)_flushMessageQueue:(NSString *)messageQueueString{
    if (messageQueueString == nil || messageQueueString.length == 0) {
        NSLog(@"WebViewJavascriptBridge: WARNING: ObjC got nil while fetching the message queue JSON from webview. This can happen if the WebViewJavascriptBridge JS is not currently present in the webview, e.g if the webview just loaded a new page.");
        return;
    }
    
    id messages = [Utils deserializeMessageJSON:messageQueueString];
    for (WVJBMessage* message in messages) {
        if (![message isKindOfClass:[WVJBMessage class]]) {
            NSLog(@"WebViewJavascriptBridge: WARNING: Invalid %@ received: %@", [message class], message);
            continue;
        }
        [Utils log:@"RCVD" json:message loggingLevel:loggingLevel];
        
        NSString* responseId = message[@"responseId"];
        if (responseId) {
            WVJBResponseCallback responseCallback = self.responseCallbacks[responseId];
            responseCallback(message[@"responseData"]);
            [self.responseCallbacks removeObjectForKey:responseId];
        } else {
            WVJBResponseCallback responseCallback = NULL;
            NSString* callbackId = message[@"callbackId"];
            if (callbackId) {
                responseCallback = ^(id responseData) {
                    if (responseData == nil) {
                        responseData = [NSNull null];
                    }
                    WVJBMessage* msg = @{ @"responseId":callbackId, @"responseData":responseData };
                    [self _queueMessage:msg];
                };
            } else {
                responseCallback = ^(id ignoreResponseData) {
                    // Do nothing
                };
            }
            
            WVJBHandler handler = self.messageHandlers[message[@"handlerName"]];
            
            if (!handler) {
                NSLog(@"WVJBNoHandlerException, No handler for message from JS: %@", message);
                continue;
            }
            handler(message[@"data"], responseCallback);
        }
    }
}
- (void)_dispatchMessage:(WVJBMessage*)message {
    
    NSString *messageJSON = [Utils serializeMessage:message pretty:NO];
    [Utils log:@"SEND" json:messageJSON loggingLevel:loggingLevel];
    messageJSON =  [Utils replacingJSONString:messageJSON];
    NSString* javascriptCommand = [NSString stringWithFormat:@"WebViewJavascriptBridge._handleMessageFromObjC('%@');", messageJSON];
    if ([[NSThread currentThread] isMainThread]) {
        [self _evaluateJavascript:javascriptCommand];
        
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self _evaluateJavascript:javascriptCommand];
        });
    }
}
+ (void)enableLogging:(Logginglevel)logginglevel {
    loggingLevel = logginglevel;
}

- (NSString *)_filterMessage:(NSString *) message {
    if (loggingLevel & LogginglevelAll) {
        NSLog(@"All WVJB RCVD:%@",message);
    }
    if (message&& [message isKindOfClass:[NSString class]] && [message containsString:kBridgePrefix])
    {
        return message;
    }
    return nil;
}
- (NSString * )_evaluateJavascript:(NSString*)javascriptCommand {
    [self evaluateJavaScript:javascriptCommand completionHandler:nil];
    return nil;
}

- (void)dealloc
{
    [self.configuration.userContentController removeScriptMessageHandlerForName:@"log"];
}
- (void)setResponseCallbacks:(NSMutableDictionary *)responseCallbacks {
    objc_setAssociatedObject(self, @selector(responseCallbacks), responseCallbacks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)responseCallbacks {
    NSMutableDictionary * responseCallbacks =  objc_getAssociatedObject(self, _cmd);
    return responseCallbacks;
}

- (void)setMessageHandlers:(NSMutableDictionary *)messageHandlers {
    objc_setAssociatedObject(self, @selector(messageHandlers), messageHandlers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)messageHandlers {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setMessageHandler:(WVJBHandler)messageHandler {
    objc_setAssociatedObject(self, @selector(messageHandler), messageHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (WVJBHandler)messageHandler {
    return objc_getAssociatedObject(self, _cmd);
}
@end
