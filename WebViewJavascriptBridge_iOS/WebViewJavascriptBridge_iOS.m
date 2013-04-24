#import "WebViewJavascriptBridge_iOS.h"

@implementation WebViewJavascriptBridge

#pragma mark UIWebViewDelegate

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
    
    [webView setDelegate:bridge];
    
    return bridge;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
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
    
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.webViewDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (webView != self.webView) { return; }
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.webViewDelegate webView:self.webView didFailLoadWithError:error];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (webView != self.webView) { return YES; }
    NSURL *url = [request URL];
    if ([[url scheme] isEqualToString:kCustomProtocolScheme]) {
        if ([[url host] isEqualToString:kQueueHasMessage]) {
            [self _flushMessageQueue];
        } else {
            NSLog(@"WebViewJavascriptBridge: WARNING: Received unknown WebViewJavascriptBridge command %@://%@", kCustomProtocolScheme, [url path]);
        }
        return NO;
    } else if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.webViewDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    } else {
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (webView != self.webView) { return; }
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.webViewDelegate webViewDidStartLoad:webView];
    }
}

@end
