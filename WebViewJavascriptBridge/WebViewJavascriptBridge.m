#import "WebViewJavascriptBridge.h"

#ifdef USE_JSONKIT
#import "JSONKit.h"
#endif

@interface WebViewJavascriptBridge ()

@property (nonatomic,strong) NSMutableArray *startupMessageQueue;
@property (nonatomic,strong) NSMutableDictionary *responseCallbacks;
@property (nonatomic,strong) NSMutableDictionary *messageHandlers;
@property (atomic,assign) NSInteger uniqueId;
@property (nonatomic, strong) UIWebView* webView;
@property (nonatomic, strong) id <UIWebViewDelegate> webViewDelegate;
@property (nonatomic, copy) WVJBHandler messageHandler;

- (void)_flushMessageQueue;
- (void)_sendData:(NSDictionary*)data responseCallback:(WVJBResponseCallback)responseCallback handlerName:(NSString*)handlerName;
- (void)_queueMessage:(NSDictionary*)message;
- (void)_dispatchMessage:(NSDictionary*)message;
- (NSString*)_serializeMessage:(NSDictionary*)message;
- (NSDictionary*)_deserializeMessageJSON:(NSString*)messageJSON;
- (void)_log:(NSString*)type json:(NSString*)output;

@end

@implementation WebViewJavascriptBridge

static NSString *MESSAGE_SEPARATOR = @"__WVJB_MESSAGE_SEPERATOR__";
static NSString *CUSTOM_PROTOCOL_SCHEME = @"wvjbscheme";
static NSString *QUEUE_HAS_MESSAGE = @"__WVJB_QUEUE_MESSAGE__";

+ (id)bridgeForWebView:(UIWebView *)webView handler:(WVJBHandler)handler {
    return [self bridgeForWebView:webView webViewDelegate:nil handler:handler];
}
    
+ (id)bridgeForWebView:(UIWebView *)webView webViewDelegate:(id<UIWebViewDelegate>)webViewDelegate handler:(WVJBHandler)messageHandler {
    WebViewJavascriptBridge* bridge = [[WebViewJavascriptBridge alloc] init];
    bridge.messageHandler = messageHandler;
    bridge.webView = webView;
    bridge.webViewDelegate = webViewDelegate;
    bridge.messageHandlers = [NSMutableDictionary dictionary];
    [bridge reset];
    webView.delegate = bridge;
    return bridge;
}

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
    [self.messageHandlers setObject:handler forKey:handlerName];
}

- (void)reset {
    self.startupMessageQueue = [NSMutableArray array];
    self.responseCallbacks = [NSMutableDictionary dictionary];
    self.uniqueId = 0;
}

- (void)_sendData:(NSDictionary *)data responseCallback:(WVJBResponseCallback)responseCallback handlerName:(NSString*)handlerName {
    NSMutableDictionary* message = [NSMutableDictionary dictionaryWithObject:data forKey:@"data"];
    
    if (responseCallback) {
        NSString* callbackId = [NSString stringWithFormat:@"objc_cb_%d", ++_uniqueId];
        [self.responseCallbacks setObject:responseCallback forKey:callbackId];
        [message setObject:callbackId forKey:@"callbackId"];
    }

    if (handlerName) {
        [message setObject:handlerName forKey:@"handlerName"];
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
        [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"WebViewJavascriptBridge._handleMessageFromObjC('%@');", messageJSON]];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"WebViewJavascriptBridge._handleMessageFromObjC('%@');", messageJSON]];
        });
    }
}

- (void)_flushMessageQueue {
    NSString *messageQueueString = [_webView stringByEvaluatingJavaScriptFromString:@"WebViewJavascriptBridge._fetchQueue();"];
    NSArray* messages = [messageQueueString componentsSeparatedByString:MESSAGE_SEPARATOR];
    for (NSString *messageJSON in messages) {
        [self _log:@"received" json:messageJSON];
        
        NSDictionary* message = [self _deserializeMessageJSON:messageJSON];
        
        NSString* responseId = [message objectForKey:@"responseId"];
        if (responseId) {
            WVJBResponseCallback responseCallback = [_responseCallbacks objectForKey:responseId];
            responseCallback([message objectForKey:@"responseData"]);
            [_responseCallbacks removeObjectForKey:responseId];
        } else {
            WVJBResponseCallback responseCallback = NULL;
            __block NSString* callbackId = [message objectForKey:@"callbackId"];
            if (callbackId) {
                __block bool wasCalled = false;
                responseCallback = ^(id responseData) {
                    if (wasCalled) { return; }
                    wasCalled = true;
                    NSDictionary* message = [NSDictionary dictionaryWithObjectsAndKeys: callbackId, @"responseId", responseData, @"responseData", nil];
                    [self _queueMessage:message];
                };
            } else {
                responseCallback = ^(id ignoreResponseData) {
                    // Do nothing
                };
            }
            
            WVJBHandler handler = self.messageHandler;

            NSString* handlerName = [message objectForKey:@"handlerName"];
            if (handlerName) {
                handler = [_messageHandlers objectForKey:handlerName];
            }
            
            if (!handler) {
                NSLog(@"WVJB Warning: No handler for %@", handlerName);
                return;
            }
            
            @try {
                NSDictionary* data = [message objectForKey:@"data"];
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

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView != _webView) { return; }

    if (![[_webView stringByEvaluatingJavaScriptFromString:@"typeof WebViewJavascriptBridge == 'object'"] isEqualToString:@"true"]) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WebViewJavascriptBridge.js" ofType:@"txt"];
        NSString *js = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        [_webView stringByEvaluatingJavaScriptFromString:js];
    }
    
    if (self.startupMessageQueue) {
        for (id queuedMessage in self.startupMessageQueue) {
            [self _dispatchMessage:queuedMessage];
        }
        self.startupMessageQueue = nil;
    }
    
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.webViewDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (webView != _webView) { return; }
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.webViewDelegate webView:_webView didFailLoadWithError:error];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (webView != _webView) { return YES; }
    NSURL *url = [request URL];
    if ([[url scheme] isEqualToString:CUSTOM_PROTOCOL_SCHEME]) {
        if ([[url host] isEqualToString:QUEUE_HAS_MESSAGE]) {
            [self _flushMessageQueue];
        } else {
            NSLog(@"WebViewJavascriptBridge: WARNING: Received unknown WebViewJavascriptBridge command %@://%@", CUSTOM_PROTOCOL_SCHEME, [url path]);
        }
        return NO;
    } else if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.webViewDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    } else {
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (webView != _webView) { return; }
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.webViewDelegate webViewDidStartLoad:webView];
    }
}

@end
