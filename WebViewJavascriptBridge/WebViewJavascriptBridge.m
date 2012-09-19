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
- (void)_queueData:(NSDictionary*)data responseCallback:(WVJBResponseCallback)responseCallback handlerName:(NSString*)handlerName;
- (void)_dispatchMessage:(NSDictionary*)message;

@end

@implementation WebViewJavascriptBridge

static NSString *MESSAGE_SEPARATOR = @"__WVJB_MESSAGE_SEPERATOR__";
static NSString *CUSTOM_PROTOCOL_SCHEME = @"wvjbscheme";
static NSString *QUEUE_HAS_MESSAGE = @"__WVJB_QUEUE_MESSAGE__";

+ (id)javascriptBridgeForWebView:(UIWebView *)webView handler:(WVJBHandler)handler {
    return [self javascriptBridgeForWebView:webView webViewDelegate:nil handler:handler];
}
    
+ (id)javascriptBridgeForWebView:(UIWebView *)webView webViewDelegate:(id<UIWebViewDelegate>)webViewDelegate handler:(WVJBHandler)messageHandler {
    WebViewJavascriptBridge* bridge = [[WebViewJavascriptBridge alloc] init];
    bridge.messageHandler = messageHandler;
    bridge.startupMessageQueue = [NSMutableArray array];
    bridge.responseCallbacks = [NSMutableDictionary dictionary];
    bridge.messageHandlers = [NSMutableDictionary dictionary];
    bridge.uniqueId = 0;
    bridge.webView = webView;
    bridge.webViewDelegate = webViewDelegate;
    webView.delegate = bridge;
    return bridge;
}

- (void)send:(NSDictionary *)data {
    [self send:data responseCallback:nil];
}

- (void)send:(NSDictionary *)data responseCallback:(WVJBResponseCallback)responseCallback {
    [self _queueData:data responseCallback:responseCallback handlerName:nil];
}

- (void)callHandler:(NSString *)handlerName {
    [self callHandler:handlerName data:nil responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    [self callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback {
    [self _queueData:data responseCallback:responseCallback handlerName:handlerName];
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    [self.messageHandlers setObject:handler forKey:handlerName];
}

- (void)_queueData:(NSDictionary *)data responseCallback:(WVJBResponseCallback)responseCallback handlerName:(NSString*)handlerName {
    NSMutableDictionary* message = [NSMutableDictionary dictionaryWithObject:data forKey:@"data"];
    
    if (responseCallback) {
        NSString* callbackId = [NSString stringWithFormat:@"objc_cb_%d", ++_uniqueId];
        [self.responseCallbacks setObject:responseCallback forKey:callbackId];
        [message setObject:callbackId forKey:@"callbackId"];
    }

    if (handlerName) {
        [message setObject:handlerName forKey:@"handlerName"];
    }
    
    if (self.startupMessageQueue) {
        [self.startupMessageQueue addObject:message];
    } else {
        [self _dispatchMessage:message];
    }
}

- (void)_dispatchMessage:(NSDictionary *)message {
#ifdef USE_JSONKIT
    NSString *messageJSON = [message JSONString];
#else
    NSString *messageJSON = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:0 error:nil] encoding:NSUTF8StringEncoding];
#endif
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"WebViewJavascriptBridge._handleMessageFromObjC('%@');", messageJSON]];
}

- (void)_flushMessageQueue {
    NSString *messageQueueString = [_webView stringByEvaluatingJavaScriptFromString:@"WebViewJavascriptBridge._fetchQueue();"];
    NSArray* messages = [messageQueueString componentsSeparatedByString:MESSAGE_SEPARATOR];
    for (NSString *messageJSON in messages) {
        // normal message - pass to bridge
#ifdef USE_JSONKIT
        NSDictionary *message = [messageJSON objectFromJSONString];
#else
        NSDictionary *message = [NSJSONSerialization JSONObjectWithData:[messageJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
#endif
        WVJBResponseCallback responseCallback = NULL;
        if ([message objectForKey:@"callbackId"]) {
            __block NSString* responseId = [message objectForKey:@"callbackId"];
            responseCallback = ^(NSDictionary* data) {
                NSDictionary* response = [NSDictionary dictionaryWithObjectsAndKeys: responseId, @"responseId", data, @"data", nil];
                [self send:response];
            };
        }
        
        WVJBHandler handler = self.messageHandler;
        if ([message objectForKey:@"handlerName"]) {
            handler = [self.messageHandlers objectForKey:[message objectForKey:@"handlerName"]];
        } else if ([message objectForKey:@"responseId"]) {
            handler = [self.responseCallbacks objectForKey:[message objectForKey:@"responseId"]];
        }
        
        @try {
            handler([message objectForKey:@"data"], responseCallback);
        }
        @catch (NSException *exception) {
            NSLog(@"WebViewJavascriptBridge: WARNING: handler threw. %@ %@", message, exception);
        }
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
    
    if (self.webViewDelegate) {
        [self.webViewDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (webView != _webView) { return; }
    if (self.webViewDelegate) {
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
    } else if (self.webViewDelegate) {
        return [self.webViewDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    } else {
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (webView != _webView) { return; }
    if (self.webViewDelegate) {
        [self.webViewDelegate webViewDidStartLoad:webView];
    }
}

@end
