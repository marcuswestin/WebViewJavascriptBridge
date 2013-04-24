#import "WebViewJavascriptBridge_OSX.h"

@implementation WebViewJavascriptBridge

+ (id)bridgeForWebView:(WebView *)webView handler:(WVJBHandler)handler {
    return [self bridgeForWebView:webView webViewDelegate:nil handler:handler];
}

+ (id)bridgeForWebView:(WebView *)webView webViewDelegate:(id)webViewDelegate handler:(WVJBHandler)messageHandler {
    WebViewJavascriptBridge* bridge = [[WebViewJavascriptBridge alloc] init];
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

- (void)webView:(WebView *)webView didFinishLoadForFrame:(WebFrame *)frame
{
    if (webView != self.webView) { return; }
    
    if (![[self.webView stringByEvaluatingJavaScriptFromString:@"typeof WebViewJavascriptBridge == 'object'"] isEqualToString:@"true"]) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WebViewJavascriptBridge.js" ofType:@"txt"];
        NSString *js = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        [self.webView stringByEvaluatingJavaScriptFromString:js];
    }
    
    if (self.startupMessageQueue) {
        for (id queuedMessage in self.startupMessageQueue) {
            [self _dispatchMessage:queuedMessage];
        }
        self.startupMessageQueue = nil;
    }
    
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didFinishLoadForFrame:)]) {
        [self.webViewDelegate webView:webView didFinishLoadForFrame:frame];
    }
}

- (void)webView:(WebView *)webView didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
    if (webView != self.webView) { return; }
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didFailLoadWithError:forFrame:)]) {
        [self.webViewDelegate webView:self.webView didFailLoadWithError:error forFrame:frame];
    }
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    if (webView != self.webView) { [listener use]; }
    NSURL *url = [request URL];
    if ([[url scheme] isEqualToString:kCustomProtocolScheme]) {
        if ([[url host] isEqualToString:kQueueHasMessage]) {
            [self _flushMessageQueue];
        } else {
            NSLog(@"WebViewJavascriptBridge: WARNING: Received unknown WebViewJavascriptBridge command %@://%@", kCustomProtocolScheme, [url path]);
        }
        [listener ignore];
    } else if ([self.webView resourceLoadDelegate]
               && [self.webViewDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:request:frame:decisionListener:)]) {
        [self.webViewDelegate webView:webView decidePolicyForNavigationAction:actionInformation request:request frame:frame decisionListener:listener];
    } else {
        [listener use];
    }
}

- (void)webView:(WebView *)webView didCommitLoadForFrame:(WebFrame *)frame {
    if (webView != self.webView) { return; }
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didCommitLoadForFrame:)]) {
        [self.webViewDelegate webView:webView didCommitLoadForFrame:frame];
    }
}

- (NSURLRequest *)webView:(WebView *)webView resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource {
    if (webView != self.webView) { return request; }
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:resource:willSendRequest:redirectResponse:fromDataSource:)]) {
        return [self.webViewDelegate webView:webView resource:identifier willSendRequest:request redirectResponse:redirectResponse fromDataSource:dataSource];
    }
    
    return request;
}

@end
