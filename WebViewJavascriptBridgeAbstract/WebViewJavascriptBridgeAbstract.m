#import "WebViewJavascriptBridgeAbstract.h"

#ifdef USE_JSONKIT
    #import "JSONKit.h"
#endif

@interface WebViewJavascriptBridgeAbstract ()

@end

@implementation WebViewJavascriptBridgeAbstract

static bool logging = false;
+ (void)enableLogging { logging = true; }

- (void)send:(NSDictionary *)data {
    [self send:data responseCallback:nil];
}

- (void)send:(NSDictionary *)data responseCallback:(WVJBResponseCallback)responseCallback {
    [self _sendData:data responseCallback:responseCallback handlerName:nil];
}

- (void)callHandler:(NSString *)handlerName {
    [self callHandler:handlerName data:nil responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    [self callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback {
    [self _sendData:data responseCallback:responseCallback handlerName:handlerName];
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    self.messageHandlers[handlerName] = [handler copy];
}

- (void)reset {
    self.startupMessageQueue = [NSMutableArray array];
    self.responseCallbacks = [NSMutableDictionary dictionary];
    self.uniqueId = 0;
}

@end

@implementation WebViewJavascriptBridgeAbstract (Protected)

- (void)_sendData:(NSDictionary *)data responseCallback:(WVJBResponseCallback)responseCallback handlerName:(NSString*)handlerName {
    NSMutableDictionary* message = [NSMutableDictionary dictionaryWithObject:data forKey:@"data"];
    
    if (responseCallback) {
        NSString* callbackId = [NSString stringWithFormat:@"objc_cb_%ld", ++self.uniqueId];
        self.responseCallbacks[callbackId] = [responseCallback copy];
        message[@"callbackId"] = callbackId;
    }
    
    if (handlerName) {
        message[@"handlerName"] = handlerName;
    }
    [self _queueMessage:message];
}

- (void)_queueMessage:(NSDictionary *)message {
    if (self.startupMessageQueue) {
        [self.startupMessageQueue addObject:message];
    } else {
        [self _dispatchMessage:message];
    }
}

- (void)_dispatchMessage:(NSDictionary *)message {
    NSString *messageJSON = [self _serializeMessage:message];
    [self _log:@"sending" json:messageJSON];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    if ([[NSThread currentThread] isMainThread]) {
        [self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:)
                           withObject:[NSString stringWithFormat:
                                       @"WebViewJavascriptBridge._handleMessageFromObjC('%@');", messageJSON]];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:)
                               withObject:[NSString stringWithFormat:
                                           @"WebViewJavascriptBridge._handleMessageFromObjC('%@');", messageJSON]];
        });
    }
}

- (void)_flushMessageQueue {
    NSString *messageQueueString = [self.webView performSelector:
                                    @selector(stringByEvaluatingJavaScriptFromString:) withObject:@"WebViewJavascriptBridge._fetchQueue();"];
    
    NSArray* messages = [messageQueueString componentsSeparatedByString:kMessageSeparator];
    for (NSString *messageJSON in messages) {
        [self _log:@"receivd" json:messageJSON];
        
        NSDictionary* message = [self _deserializeMessageJSON:messageJSON];
        
        NSString* responseId = message[@"responseId"];
        if (responseId) {
            WVJBResponseCallback responseCallback = self.responseCallbacks[responseId];
            responseCallback(message[@"responseData"]);
            [self.responseCallbacks removeObjectForKey:responseId];
        } else {
            WVJBResponseCallback responseCallback = NULL;
            __block NSString* callbackId = message[@"callbackId"];
            if (callbackId) {
                responseCallback = ^(id responseData) {
                    NSDictionary* message = @{ @"responseId":callbackId, @"responseData":responseData };
                    [self _queueMessage:message];
                };
            } else {
                responseCallback = ^(id ignoreResponseData) {
                    // Do nothing
                };
            }
            
            WVJBHandler handler;
            if (message[@"handlerName"]) {
                handler = self.messageHandlers[message[@"handlerName"]];
                if (!handler) { return NSLog(@"WVJB Warning: No handler for %@", message[@"handlerName"]); }
            } else {
                handler = self.messageHandler;
            }
            
            @try {
                NSDictionary* data = message[@"data"];
                if (!data || ((id)data) == [NSNull null]) { data = [NSDictionary dictionary]; }
                handler(data, responseCallback);
            }
            @catch (NSException *exception) {
                NSLog(@"WebViewJavascriptBridge: WARNING: objc handler threw. %@ %@", message, exception);
            }
        }
    }
}

- (NSString *)_serializeMessage:(NSDictionary *)message {
#ifdef USE_JSONKIT
    return [message JSONString];
#else
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:0 error:nil] encoding:NSUTF8StringEncoding];
#endif
}

- (NSDictionary *)_deserializeMessageJSON:(NSString *)messageJSON {
#ifdef USE_JSONKIT
    return [messageJSON objectFromJSONString];
#else
    return [NSJSONSerialization JSONObjectWithData:[messageJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
#endif
}

- (void)_log:(NSString *)action json:(NSString *)json {
    if (!logging) { return; }
    if (json.length > 500) {
        NSLog(@"WVJB %@: %@", action, [[json substringToIndex:500] stringByAppendingString:@" [...]"]);
    } else {
        NSLog(@"WVJB %@: %@", action, json);
    }
}

@end
