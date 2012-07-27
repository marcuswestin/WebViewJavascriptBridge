#import "WebViewJavascriptBridge.h"
#import "JSONKit.h"

@interface WebViewJavascriptBridge ()

@property (nonatomic,strong) NSMutableArray *startupMessageQueue;
@property (nonatomic,strong) NSMutableDictionary *javascriptCallbacks;

- (void)_flushMessageQueueFromWebView:(UIWebView *)webView;
- (void)_doSendMessage:(NSString*)message toWebView:(UIWebView *)webView;

@end

@implementation WebViewJavascriptBridge

@synthesize delegate = _delegate;
@synthesize startupMessageQueue = _startupMessageQueue;

static NSString *MESSAGE_SEPARATOR = @"__wvjb_sep__";
static NSString *CUSTOM_PROTOCOL_SCHEME = @"webviewjavascriptbridge";
static NSString *QUEUE_HAS_MESSAGE = @"queuehasmessage";
static NSString *CALLBACK_MESSAGE_PREFIX = @"__wvjb_cb__";
static NSString *CALLBACK_FUNCTION_KEY = @"wvjb_function";
static NSString *CALLBACK_ARGUMENTS_KEY = @"wvjb_arguments";

+ (id)javascriptBridgeWithDelegate:(id <WebViewJavascriptBridgeDelegate>)delegate {
    WebViewJavascriptBridge* bridge = [[[WebViewJavascriptBridge alloc] init] autorelease];
    bridge.delegate = delegate;
	[bridge resetQueue];
    return bridge;
}

- (id)init {
    if (self = [super init]) {
        self.javascriptCallbacks = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)dealloc {
    _delegate = nil;
    [_startupMessageQueue release];
    [_javascriptCallbacks release];

    [super dealloc];
}

- (void)sendMessage:(NSString *)message toWebView:(UIWebView *)webView {
    if (self.startupMessageQueue) { [self.startupMessageQueue addObject:message]; }
    else { [self _doSendMessage:message toWebView: webView]; }
}

- (void)resetQueue {
    self.startupMessageQueue = [[[NSMutableArray alloc] init] autorelease];
}

- (void)registerJavascriptCallback:(NSString *)name withCallback:(void (^)(NSDictionary *params))callback {
    [self.javascriptCallbacks setObject:callback forKey:name];
}

- (void)unregisterJavascriptCallback:(NSString *)name {
    [self.javascriptCallbacks removeObjectForKey:name];
}

- (void)_doSendMessage:(NSString *)message toWebView:(UIWebView *)webView {
    message = [message stringByReplacingOccurrencesOfString:@"\\n" withString:@"\\\\n"];
    message = [message stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    message = [message stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"WebViewJavascriptBridge._handleMessageFromObjC('%@');", message]];
}

- (void)_flushMessageQueueFromWebView:(UIWebView *)webView {
    NSString *messageQueueString = [webView stringByEvaluatingJavaScriptFromString:@"WebViewJavascriptBridge._fetchQueue();"];
    NSArray* messages = [messageQueueString componentsSeparatedByString:MESSAGE_SEPARATOR];
    for (NSString *message in messages) {
        if ([message hasPrefix:CALLBACK_MESSAGE_PREFIX]) {
            // should be a JSON encoded callback
            NSDictionary *decodedMessage = [[message stringByReplacingOccurrencesOfString:CALLBACK_MESSAGE_PREFIX withString:@""] objectFromJSONString];
            NSString *callbackName = [decodedMessage objectForKey:CALLBACK_FUNCTION_KEY];

            void (^callback)(NSDictionary *params) = [self.javascriptCallbacks objectForKey:callbackName];

            if (callback == NULL) {
                // don't have a callback - pass to bridge
                [self.delegate javascriptBridge:self receivedMessage:message fromWebView:webView];
            } else {
                // call the callback
                callback([decodedMessage objectForKey:CALLBACK_ARGUMENTS_KEY]);
            }
        }
        else {
            // normal message - pass to bridge
            [self.delegate javascriptBridge:self receivedMessage:message fromWebView:webView];
        }
    }
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *js = [NSString stringWithFormat:@";(function() {"
        "if (window.WebViewJavascriptBridge) { return; };"
        "var _readyMessageIframe,"
        "     _sendMessageQueue = [],"
        "     _receiveMessageQueue = [],"
        "     _MESSAGE_SEPERATOR = '%@',"
        "     _CUSTOM_PROTOCOL_SCHEME = '%@',"
        "     _QUEUE_HAS_MESSAGE = '%@',"
        "     _CALLBACK_MESSAGE_PREFIX = '%@',"
        "     _CALLBACK_FUNCTION_KEY = '%@',"
        "     _CALLBACK_ARGUMENTS_KEY = '%@';"
        ""                    
        "function _createQueueReadyIframe(doc) {"
        "     _readyMessageIframe = doc.createElement('iframe');"
        "     _readyMessageIframe.style.display = 'none';"
        "     doc.documentElement.appendChild(_readyMessageIframe);"
        "}"
        ""
        "function _sendMessage(message) {"
        "     _sendMessageQueue.push(message);"
        "     _readyMessageIframe.src = _CUSTOM_PROTOCOL_SCHEME + '://' + _QUEUE_HAS_MESSAGE;"
        "};"
        "function _callCallback(name, params) {"
        "     var payload = {};"
        "     payload[_CALLBACK_FUNCTION_KEY] = name;"
        "     payload[_CALLBACK_ARGUMENTS_KEY] = params;"
        "     _sendMessage(_CALLBACK_MESSAGE_PREFIX + JSON.stringify(payload));"
        "};"
        ""
        "function _fetchQueue() {"
        "     var messageQueueString = _sendMessageQueue.join(_MESSAGE_SEPERATOR);"
        "     _sendMessageQueue = [];"
        "     return messageQueueString;"
        "};"
        ""
        "function _setMessageHandler(messageHandler) {"
        "     if (WebViewJavascriptBridge._messageHandler) { return alert('WebViewJavascriptBridge.setMessageHandler called twice'); }"
        "     WebViewJavascriptBridge._messageHandler = messageHandler;"
        "     var receivedMessages = _receiveMessageQueue;"
        "     _receiveMessageQueue = null;"
        "     for (var i=0; i<receivedMessages.length; i++) {"
        "         messageHandler(receivedMessages[i]);"
        "     }"
        "};"
        ""
        "function _handleMessageFromObjC(message) {"
        "     if (_receiveMessageQueue) { _receiveMessageQueue.push(message); }"
        "     else { WebViewJavascriptBridge._messageHandler(message); }"
        "};"
        ""
        "window.WebViewJavascriptBridge = {"
        "     setMessageHandler: _setMessageHandler,"
        "     sendMessage: _sendMessage,"
        "     callCallback: _callCallback,"
        "     _fetchQueue: _fetchQueue,"
        "     _handleMessageFromObjC: _handleMessageFromObjC"
        "};"
        ""
        "var doc = document;"
        "_createQueueReadyIframe(doc);"
        "var readyEvent = doc.createEvent('Events');"
        "readyEvent.initEvent('WebViewJavascriptBridgeReady');"
        "doc.dispatchEvent(readyEvent);"
        ""
        "})();",
        MESSAGE_SEPARATOR,
        CUSTOM_PROTOCOL_SCHEME,
        QUEUE_HAS_MESSAGE,
        CALLBACK_MESSAGE_PREFIX,
        CALLBACK_FUNCTION_KEY,
        CALLBACK_ARGUMENTS_KEY];
    
    if (![[webView stringByEvaluatingJavaScriptFromString:@"typeof WebViewJavascriptBridge == 'object'"] isEqualToString:@"true"]) {
        [webView stringByEvaluatingJavaScriptFromString:js];
    }
    
    for (id message in self.startupMessageQueue) {
        [self _doSendMessage:message toWebView: webView];
    }

    self.startupMessageQueue = nil;

    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:webView didFailLoadWithError:error];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    if (![[url scheme] isEqualToString:CUSTOM_PROTOCOL_SCHEME]) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
            return [self.delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
        }
        return YES;
    }

    if ([[url host] isEqualToString:QUEUE_HAS_MESSAGE]) {
        [self _flushMessageQueueFromWebView: webView];
    } else {
        NSLog(@"WebViewJavascriptBridge: WARNING: Received unknown WebViewJavascriptBridge command %@://%@", CUSTOM_PROTOCOL_SCHEME, [url path]);
    }

    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:webView];
    }
}

@end
