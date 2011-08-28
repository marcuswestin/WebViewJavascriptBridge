#import "WebViewJavascriptBridge.h"

@implementation WebViewJavascriptBridge

@synthesize secret;
@synthesize delegate;
@synthesize webView;
@synthesize startupMessageQueue;

static NSString* MESSAGE_SEPERATOR = @"__wvjb_sep__";
static NSString* CUSTOM_PROTOCOL_SCHEME = @"webviewjavascriptbridge";
static NSString* QUEUE_HAS_MESSAGE = @"queuehasmessage";

+ (id) createWithDelegate:(id <WebViewJavascriptBridgeDelegate>) delegate {
    WebViewJavascriptBridge* bridge = [[WebViewJavascriptBridge alloc] init];
    bridge.delegate = delegate;
    bridge.secret = [NSString stringWithFormat:@"%d", arc4random()];
    bridge.startupMessageQueue = [[NSMutableArray alloc] init];
    return bridge;
}

- (void)sendMessage:(NSString *)message {
    if (startupMessageQueue) { [startupMessageQueue addObject:message]; }
    else { [self _doSendMessage:message]; }
}

- (void)_doSendMessage:(NSString *)message {
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"WebViewJavascriptBridge._handleMessageFromObjC('%@');", message]];
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
    webView = theWebView;
    NSString* js;
    js = [NSString stringWithFormat:@";(function() {"
          "if (window.WebViewJavascriptBridge) { return; };"
          "var _readyMessageIframe,"
          "     _sendMessageQueue = [],"
          "     _receiveMessageQueue = [],"
          "     _MESSAGE_SEPERATOR = '%@',"
          "     _CUSTOM_PROTOCOL_SCHEME = '%@',"
          "     _QUEUE_HAS_MESSAGE = '%@';"
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
          "     _fetchQueue: _fetchQueue,"
          "     _handleMessageFromObjC: _handleMessageFromObjC"
          "};"
          ""
          "setTimeout(function() {"
          "     var doc = document;"
          "     _createQueueReadyIframe(doc);"
          "     var readyEvent = doc.createEvent('Events');"
          "     readyEvent.initEvent('WebViewJavascriptBridgeReady');"
          "     doc.dispatchEvent(readyEvent);"
          "}, 0);"
          "})();",
          MESSAGE_SEPERATOR,
          CUSTOM_PROTOCOL_SCHEME,
          QUEUE_HAS_MESSAGE];
    
    [webView stringByEvaluatingJavaScriptFromString:js];
    
    for (id message in startupMessageQueue) {
        [self _doSendMessage:message];
    }
    startupMessageQueue = nil;
}


- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    NSLog(@"shouldStartLoadWithRequest %@ %@", [url scheme], [url host]);
    if (![[url scheme] isEqualToString:CUSTOM_PROTOCOL_SCHEME]) { return YES; }

    if ([[url host] isEqualToString:QUEUE_HAS_MESSAGE]) {
        [self _flushMessageQueue];
    } else {
        NSLog(@"WARNING: Received unknown WebViewJavascriptBridge command %@://%@", CUSTOM_PROTOCOL_SCHEME, [url path]);
    }
    
    return NO;
}

- (void) _flushMessageQueue {
    NSString* messageQueueString = [webView stringByEvaluatingJavaScriptFromString:@"WebViewJavascriptBridge._fetchQueue();"];
    NSArray* messages = [messageQueueString componentsSeparatedByString:MESSAGE_SEPERATOR];
    for (id message in messages) {
        [delegate handleMessage:message];
    }
}

@end
