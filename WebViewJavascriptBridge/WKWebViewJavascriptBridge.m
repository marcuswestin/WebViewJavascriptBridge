//
//  WKWebViewJavascriptBridge.m
//
//  Created by Loki Meyburg on 10/15/14.
//  Copyright (c) 2014 Loki Meyburg. All rights reserved.
//


#import "WKWebViewJavascriptBridge.h"

#if defined(supportsWKWebKit)

typedef NSDictionary WVJBMessage;

@implementation WKWebViewJavascriptBridge {
    WKWebView* _webView;
    id _webViewDelegate;
    NSMutableArray* _startupMessageQueue;
    NSMutableDictionary* _responseCallbacks;
    NSMutableDictionary* _messageHandlers;
    long _uniqueId;
    WVJBHandler _messageHandler;
    NSBundle *_resourceBundle;
    NSUInteger _numRequestsLoading;
}

/* API
 *****/

static bool logging = false;
+ (void)enableLogging { logging = true; }

+ (instancetype)bridgeForWebView:(WKWebView*)webView handler:(WVJBHandler)handler {
    return [self bridgeForWebView:webView webViewDelegate:nil handler:handler];
}

+ (instancetype)bridgeForWebView:(WKWebView*)webView webViewDelegate:(NSObject<WKNavigationDelegate>*)webViewDelegate handler:(WVJBHandler)messageHandler {
    return [self bridgeForWebView:webView webViewDelegate:webViewDelegate handler:messageHandler resourceBundle:nil];
}

+ (instancetype)bridgeForWebView:(WKWebView*)webView webViewDelegate:(NSObject<WKNavigationDelegate>*)webViewDelegate handler:(WVJBHandler)messageHandler resourceBundle:(NSBundle*)bundle
{
    WKWebViewJavascriptBridge* bridge = [[WKWebViewJavascriptBridge alloc] init];
    [bridge _platformSpecificSetup:webView webViewDelegate:webViewDelegate handler:messageHandler resourceBundle:bundle];
    [bridge reset];
    return bridge;
}

- (void)send:(id)data {
    [self send:data responseCallback:nil];
}

- (void)send:(id)data responseCallback:(WVJBResponseCallback)responseCallback {
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
    _messageHandlers[handlerName] = [handler copy];
}

- (void)reset {
    _startupMessageQueue = [NSMutableArray array];
    _responseCallbacks = [NSMutableDictionary dictionary];
    _uniqueId = 0;
}

/* Internals
 ***********/

- (void)dealloc {
    [self _platformSpecificDealloc];
    
    _webView = nil;
    _webViewDelegate = nil;
    _startupMessageQueue = nil;
    _responseCallbacks = nil;
    _messageHandlers = nil;
    _messageHandler = nil;
}

- (void)_sendData:(id)data responseCallback:(WVJBResponseCallback)responseCallback handlerName:(NSString*)handlerName {
    NSMutableDictionary* message = [NSMutableDictionary dictionary];
    
    if (data) {
        message[@"data"] = data;
    }
    
    if (responseCallback) {
        NSString* callbackId = [NSString stringWithFormat:@"objc_cb_%ld", ++_uniqueId];
        _responseCallbacks[callbackId] = [responseCallback copy];
        message[@"callbackId"] = callbackId;
    }
    
    if (handlerName) {
        message[@"handlerName"] = handlerName;
    }
    [self _queueMessage:message];
}

- (void)_queueMessage:(WVJBMessage*)message {
    if (_startupMessageQueue) {
        [_startupMessageQueue addObject:message];
    } else {
        [self _dispatchMessage:message];
    }
}

- (void)_dispatchMessage:(WVJBMessage*)message {
    NSString *messageJSON = [self _serializeMessage:message];
    [self _log:@"SEND" json:messageJSON];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    
    NSString* javascriptCommand = [NSString stringWithFormat:@"WebViewJavascriptBridge._handleMessageFromObjC('%@');", messageJSON];
    if ([[NSThread currentThread] isMainThread]) {
        [_webView evaluateJavaScript:javascriptCommand completionHandler:nil];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_webView evaluateJavaScript:javascriptCommand completionHandler:nil];
        });
    }
}

- (void)_flushMessageQueue:(NSString *)messageQueueString{
    id messages = [self _deserializeMessageJSON:messageQueueString];
    if (![messages isKindOfClass:[NSArray class]]) {
        NSLog(@"WKWebViewJavascriptBridge: WARNING: Invalid %@ received: %@", [messages class], messages);
        return;
    }
    for (WVJBMessage* message in messages) {
        if (![message isKindOfClass:[WVJBMessage class]]) {
            NSLog(@"WKWebViewJavascriptBridge: WARNING: Invalid %@ received: %@", [message class], message);
            continue;
        }
        [self _log:@"RCVD" json:message];
        
        NSString* responseId = message[@"responseId"];
        if (responseId) {
            WVJBResponseCallback responseCallback = _responseCallbacks[responseId];
            responseCallback(message[@"responseData"]);
            [_responseCallbacks removeObjectForKey:responseId];
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
            
            WVJBHandler handler;
            if (message[@"handlerName"]) {
                handler = _messageHandlers[message[@"handlerName"]];
            } else {
                handler = _messageHandler;
            }
            
            if (!handler) {
                [NSException raise:@"WVJBNoHandlerException" format:@"No handler for message from JS: %@", message];
            }
            
            handler(message[@"data"], responseCallback);
        }
    }
}

- (NSString *)_serializeMessage:(id)message {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:0 error:nil] encoding:NSUTF8StringEncoding];
}

- (NSArray*)_deserializeMessageJSON:(NSString *)messageJSON {
    return [NSJSONSerialization JSONObjectWithData:[messageJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}

- (void)_log:(NSString *)action json:(id)json {
    if (!logging) { return; }
    if (![json isKindOfClass:[NSString class]]) {
        json = [self _serializeMessage:json];
    }
    if ([json length] > 500) {
        NSLog(@"WVJB %@: %@ [...]", action, [json substringToIndex:500]);
    } else {
        NSLog(@"WVJB %@: %@", action, json);
    }
}




/* WKWebView Specific Internals
 ******************************/

- (void) _platformSpecificSetup:(WKWebView*)webView webViewDelegate:(id<WKNavigationDelegate>)webViewDelegate handler:(WVJBHandler)messageHandler resourceBundle:(NSBundle*)bundle{
    _messageHandler = messageHandler;
    _webView = webView;
    _webViewDelegate = webViewDelegate;
    _messageHandlers = [NSMutableDictionary dictionary];
    _webView.navigationDelegate = self;
    _resourceBundle = bundle;
}

- (void) _platformSpecificDealloc {
    _webView.navigationDelegate = nil;
}


- (void)WKFlushMessageQueue {
    [_webView evaluateJavaScript:@"WebViewJavascriptBridge._fetchQueue();" completionHandler:^(NSString* result, NSError* error) {
        [self _flushMessageQueue:result];
    }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (webView != _webView) { return; }
    
    _numRequestsLoading--;
    
    if (_numRequestsLoading == 0) {
        [webView evaluateJavaScript:@"typeof WebViewJavascriptBridge == \'object\';" completionHandler:^(NSString *result, NSError *error) {
            if(![result boolValue]){
                NSBundle *bundle = _resourceBundle ? _resourceBundle : [NSBundle mainBundle];
                NSString *filePath = [bundle pathForResource:@"WebViewJavascriptBridge.js" ofType:@"txt"];
                NSString *js = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                [webView evaluateJavaScript:js completionHandler:nil];
                
                if (_startupMessageQueue) {
                    for (id queuedMessage in _startupMessageQueue) {
                        [self _dispatchMessage:queuedMessage];
                    }
                    _startupMessageQueue = nil;
                }
            }
        }];
    }
    
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        [strongDelegate webView:webView didFinishNavigation:navigation];
    }
}


- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (webView != _webView) { return; }
    NSURL *url = navigationAction.request.URL;
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if ([[url scheme] isEqualToString:kCustomProtocolScheme]) {
        if ([[url host] isEqualToString:kQueueHasMessage]) {
            [self WKFlushMessageQueue];
        } else {
            NSLog(@"WKWebViewJavascriptBridge: WARNING: Received unknown WKWebViewJavascriptBridge command %@://%@", kCustomProtocolScheme, [url path]);
        }
        [webView stopLoading];
    }
    
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [_webViewDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if (webView != _webView) { return; }
    
    _numRequestsLoading++;
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
        [strongDelegate webView:webView didStartProvisionalNavigation:navigation];
    }
}


- (void)webView:(WKWebView *)webView
didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    
    if (webView != _webView) { return; }
    
    _numRequestsLoading--;
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFailNavigation:withError:)]) {
        [strongDelegate webView:webView didFailNavigation:navigation withError:error];
    }
}



@end


#endif
