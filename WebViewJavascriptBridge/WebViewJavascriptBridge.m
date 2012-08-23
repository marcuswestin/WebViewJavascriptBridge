#import "WebViewJavascriptBridge.h"

#ifdef USE_JSONKIT
#import "JSONKit.h"
#endif

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
    WebViewJavascriptBridge* bridge = [[WebViewJavascriptBridge alloc] init];
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
}

- (void)sendMessage:(NSString *)message toWebView:(UIWebView *)webView {
    if (self.startupMessageQueue) {
        [self.startupMessageQueue addObject:message];
    } else {
        [self _doSendMessage:message toWebView: webView];
    }
}

- (void)resetQueue {
    self.startupMessageQueue = [[NSMutableArray alloc] init];
}

- (void)callJavascriptCallback:(NSString *)name toWebView:(UIWebView *)webView {
    [self callJavascriptCallback:name withParams:[NSDictionary dictionary] toWebView:webView];
}

- (void)callJavascriptCallback:(NSString *)name withParams:(NSDictionary *)params toWebView:(UIWebView *)webView {
    NSDictionary *callParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                name, CALLBACK_FUNCTION_KEY,
                                params, CALLBACK_ARGUMENTS_KEY,
                                nil];
#ifdef USE_JSONKIT
    NSString *encodedParams = [callParams JSONString];
#else
    NSString *encodedParams = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:callParams options:0 error:nil]
                                                    encoding:NSUTF8StringEncoding];
#endif

    [self sendMessage:[NSString stringWithFormat:@"%@%@", CALLBACK_MESSAGE_PREFIX, encodedParams]
            toWebView:webView];
}

- (void)registerObjcCallback:(NSString *)name withCallback:(void (^)(NSDictionary *params))callback {
    [self.javascriptCallbacks setObject:[callback copy] forKey:name];
}

- (void)unregisterObjcCallback:(NSString *)name {
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
            NSString *payload = [message stringByReplacingOccurrencesOfString:CALLBACK_MESSAGE_PREFIX withString:@""];
#ifdef USE_JSONKIT
            NSDictionary *decodedMessage = [payload objectFromJSONString];
#else
            NSDictionary *decodedMessage = [NSJSONSerialization JSONObjectWithData:[payload dataUsingEncoding:NSUTF8StringEncoding]
                                                                           options:0
                                                                             error:nil];
#endif
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
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WebViewJavascriptBridge" ofType:@"js"];
    NSString *jsTemplate = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSString *js = [NSString stringWithFormat:jsTemplate,
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
