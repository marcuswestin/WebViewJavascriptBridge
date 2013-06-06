#import "WebViewJavascriptBridge_OSX.h"

@interface WebViewJavascriptBridge ()

@property (nonatomic, assign) NSUInteger numRequestsLoading;

@end

@implementation WebViewJavascriptBridge

+ (instancetype)bridgeForWebView:(WebView *)webView handler:(WVJBHandler)handler {
    return [self bridgeForWebView:webView webViewDelegate:nil handler:handler];
}

+ (instancetype)bridgeForWebView:(WebView *)webView webViewDelegate:(id)webViewDelegate handler:(WVJBHandler)messageHandler {
    WebViewJavascriptBridge* bridge = [[[self class] alloc] init];
    bridge.messageHandler = messageHandler;
    bridge.webView = webView;
    bridge.webViewDelegate = webViewDelegate;
    bridge.messageHandlers = [NSMutableDictionary dictionary];
    [bridge reset];
    
    bridge.webView.frameLoadDelegate = bridge;
    bridge.webView.resourceLoadDelegate = bridge;
    bridge.webView.policyDelegate = bridge;
        
    return bridge;
}

- (void)dealloc;
{
    self.webView.frameLoadDelegate = nil;
    self.webView.resourceLoadDelegate = nil;
    self.webView.policyDelegate = nil;
}

- (void)webView:(WebView *)webView didFinishLoadForFrame:(WebFrame *)frame
{
    if (webView != self.webView) { return; }
    
    self.numRequestsLoading--;

    if (self.numRequestsLoading == 0 && ![[webView stringByEvaluatingJavaScriptFromString:@"typeof WebViewJavascriptBridge == 'object'"] isEqualToString:@"true"]) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WebViewJavascriptBridge.js" ofType:@"txt"];
        NSString *js = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        [webView stringByEvaluatingJavaScriptFromString:js];
    }
    
    if (self.startupMessageQueue) {
        for (id queuedMessage in self.startupMessageQueue) {
            [self _dispatchMessage:queuedMessage];
        }
        self.startupMessageQueue = nil;
    }
    
    __strong typeof(self.webViewDelegate) strongDelegate = self.webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFinishLoadForFrame:)]) {
        [strongDelegate webView:webView didFinishLoadForFrame:frame];
    }
}

- (void)webView:(WebView *)webView didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
    if (webView != self.webView) { return; }

    self.numRequestsLoading--;

    __strong typeof(self.webViewDelegate) strongDelegate = self.webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFailLoadWithError:forFrame:)]) {
        [strongDelegate webView:strongDelegate didFailLoadWithError:error forFrame:frame];
    }
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    if (webView != self.webView) { [listener use]; }
    NSURL *url = [request URL];
    __strong typeof(self.webViewDelegate) strongDelegate = self.webViewDelegate;
    if ([[url scheme] isEqualToString:kCustomProtocolScheme]) {
        if ([[url host] isEqualToString:kQueueHasMessage]) {
            [self _flushMessageQueue];
        } else {
            NSLog(@"WebViewJavascriptBridge: WARNING: Received unknown WebViewJavascriptBridge command %@://%@", kCustomProtocolScheme, [url path]);
        }
        [listener ignore];
    } else if ([webView resourceLoadDelegate]
               && [strongDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:request:frame:decisionListener:)]) {
        [strongDelegate webView:webView decidePolicyForNavigationAction:actionInformation request:request frame:frame decisionListener:listener];
    } else {
        [listener use];
    }
}

- (void)webView:(WebView *)webView didCommitLoadForFrame:(WebFrame *)frame {
    if (webView != self.webView) { return; }
    __strong typeof(self.webViewDelegate) strongDelegate = self.webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didCommitLoadForFrame:)]) {
        [strongDelegate webView:webView didCommitLoadForFrame:frame];
    }
}

- (NSURLRequest *)webView:(WebView *)webView resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource {
    if (webView != self.webView) { return request; }
    
    self.numRequestsLoading++;

    __strong typeof(self.webViewDelegate) strongDelegate = self.webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:resource:willSendRequest:redirectResponse:fromDataSource:)]) {
        return [strongDelegate webView:webView resource:identifier willSendRequest:request redirectResponse:redirectResponse fromDataSource:dataSource];
    }
    
    return request;
}

@end
