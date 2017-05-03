//
//  WebViewJavascriptBridge.m
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 6/14/13.
//  Copyright (c) 2013 Marcus Westin. All rights reserved.
//

#import "WebViewJavascriptBridge.h"

@interface WebViewJavascriptBridge ()

@property (strong, nonatomic) WVJB_WEBVIEW_TYPE *webView;
@property (strong, nonatomic) WebViewJavascriptBridgeBase *base;

@end

@implementation WebViewJavascriptBridge

/* API
 *****/

+ (void)enableLogging {
    [WebViewJavascriptBridgeBase enableLogging];
}

+ (void)setLogMaxLength:(int)length {
    [WebViewJavascriptBridgeBase setLogMaxLength:length];
}

+ (instancetype)bridgeForWebView:(id)webView {
    return [self bridge:webView];
}
+ (instancetype)bridge:(id)webView {
#if defined supportsWKWebView
    if ([webView isKindOfClass:[WKWebView class]]) {
        return (WebViewJavascriptBridge*) [WKWebViewJavascriptBridge bridgeForWebView:webView];
    }
#endif
    if ([webView isKindOfClass:[WVJB_WEBVIEW_TYPE class]]) {
        WebViewJavascriptBridge* bridge = [[self alloc] init];
        [bridge _platformSpecificSetup:webView];
        return bridge;
    }
    [NSException raise:@"BadWebViewType" format:@"Unknown web view type."];
    return nil;
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

- (void)disableJavscriptAlertBoxSafetyTimeout {
    [self.base disableJavscriptAlertBoxSafetyTimeout];
}


/* Platform agnostic internals
 *****************************/

- (NSString*) _evaluateJavascript:(NSString*)javascriptCommand
{
    return [self.webView stringByEvaluatingJavaScriptFromString:javascriptCommand];
}

#if defined WVJB_PLATFORM_OSX
/* Platform specific internals: OSX
 **********************************/

- (void) _platformSpecificSetup:(WVJB_WEBVIEW_TYPE*)webView {
    _webView = webView;
    _webView.policyDelegate = self;
    _base = [[WebViewJavascriptBridgeBase alloc] init];
    _base.delegate = self;
}


- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:request:frame:decisionListener:)]) {
        [self.webViewDelegate webView:webView decidePolicyForNavigationAction:actionInformation request:request frame:frame decisionListener:listener]; {
        return;
    }
        
    NSURL *url = [request URL];
    if ([self.base isCorrectProcotocolScheme:url]) {
        if ([self.base isBridgeLoadedURL:url]) {
            [self.base injectJavascriptFile];
        } else if ([self.base isQueueMessageURL:url]) {
            NSString *messageQueueString = [self _evaluateJavascript:[self.base webViewJavascriptFetchQueyCommand]];
            [self.base flushMessageQueue:messageQueueString];
        } else {
            [self.base logUnkownMessage:url];
        }
        [listener ignore];
    } else {
        [listener use];
    }
}



#elif defined WVJB_PLATFORM_IOS
/* Platform specific internals: iOS
 **********************************/

- (void) _platformSpecificSetup:(WVJB_WEBVIEW_TYPE*)webView {
    _webView = webView;
    _webView.delegate = self;
    _base = [[WebViewJavascriptBridgeBase alloc] init];
    _base.delegate = self;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.webViewDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.webViewDelegate webView:webView didFailLoadWithError:error];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.webViewDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    NSURL *url = [request URL];
    
    if ([self.base isCorrectProcotocolScheme:url]) {
        
        if ([self.base isBridgeLoadedURL:url]) {
            [self.base injectJavascriptFile];
        } else if ([self.base isQueueMessageURL:url]) {
            NSString *messageQueueString = [self _evaluateJavascript:[self.base webViewJavascriptFetchQueyCommand]];
            [self.base flushMessageQueue:messageQueueString];
        } else {
            [self.base logUnkownMessage:url];
        }
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.webViewDelegate webViewDidStartLoad:webView];
    }
}

#endif

@end
