//
//  WKWebViewJavascriptBridge.m
//
//  Created by @LokiMeyburg on 10/15/14.
//  Copyright (c) 2014 @LokiMeyburg. All rights reserved.
//


#import "WKWebViewJavascriptBridge.h"

#if defined supportsWKWebView

@interface WKWebViewJavascriptBridge ()

@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) WebViewJavascriptBridgeBase *base;

@end

@implementation WKWebViewJavascriptBridge 

/* API
 *****/

+ (void)enableLogging { [WebViewJavascriptBridgeBase enableLogging]; }

+ (instancetype)bridgeForWebView:(WKWebView*)webView {
    WKWebViewJavascriptBridge* bridge = [[self alloc] init];
    [bridge _setupInstance:webView];
    [bridge reset];
    return bridge;
}

- (void)send:(id)data {
    [self send:data responseCallback:nil];
}

- (void)send:(id)data responseCallback:(WVJBResponseCallback)responseCallback {
    [self.base sendData:data responseCallback:responseCallback handlerName:nil];
}

- (void)callHandler:(NSString *)handlerName {
    [self callHandler:handlerName data:nil responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    [self callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback {
    [self.base sendData:data responseCallback:responseCallback handlerName:handlerName];
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    self.base.messageHandlers[handlerName] = [handler copy];
}

- (void)removeHandler:(NSString *)handlerName {
    [_base.messageHandlers removeObjectForKey:handlerName];
}

- (void)reset {
    [self.base reset];
}

- (void)disableJavscriptAlertBoxSafetyTimeout {
    [self.base disableJavscriptAlertBoxSafetyTimeout];
}


/* WKWebView Specific Internals
 ******************************/

- (void) _setupInstance:(WKWebView*)webView {
    _webView = webView;
    _webView.navigationDelegate = self;
    _base = [[WebViewJavascriptBridgeBase alloc] init];
    _base.delegate = self;
}


- (void)WKFlushMessageQueue {
    [self.webView evaluateJavaScript:[self.base webViewJavascriptFetchQueyCommand] completionHandler:^(NSString* result, NSError* error) {
        if (error != nil) {
            NSLog(@"WebViewJavascriptBridge: WARNING: Error when trying to fetch data from WKWebView: %@", error);
        }
        [self.base flushMessageQueue:result];
    }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        [self.webViewDelegate webView:webView didFinishNavigation:navigation];
    }
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationResponse:decisionHandler:)]) {
        [self.webViewDelegate webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
        return;
    }
    
    if (decisionHandler) {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didReceiveAuthenticationChallenge:completionHandler:)]) {
        [self.webViewDelegate webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
        return;
    }
    
    if (completionHandler) {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    if ([self.base isCorrectProcotocolScheme:url]) {
        if ([self.base isBridgeLoadedURL:url]) {
            [self.base injectJavascriptFile];
        } else if ([self.base isQueueMessageURL:url]) {
            [self WKFlushMessageQueue];
        } else {
            [self.base logUnkownMessage:url];
        }
        if (decisionHandler) {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    }
    
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [self.webViewDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
        return;
    }
    
    if (decisionHandler) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
        [self.webViewDelegate webView:webView didStartProvisionalNavigation:navigation];
    }
}


- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didFailNavigation:withError:)]) {
        [self.webViewDelegate webView:webView didFailNavigation:navigation withError:error];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)]) {
        [self.webViewDelegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
}

- (NSString*) _evaluateJavascript:(NSString*)javascriptCommand
{
    [self.webView evaluateJavaScript:javascriptCommand completionHandler:nil];
    return nil;
}

@end


#endif
