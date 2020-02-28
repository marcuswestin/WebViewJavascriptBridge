//
//  WebViewJavascriptBridge.m
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 6/14/13.
//  Copyright (c) 2013 Marcus Westin. All rights reserved.
//

#import "WebViewJavascriptBridge.h"

#if defined(supportsWKWebView)
#import "WKWebViewJavascriptBridge.h"
#endif

#if __has_feature(objc_arc_weak)
    #define WVJB_WEAK __weak
#else
    #define WVJB_WEAK __unsafe_unretained
#endif

@implementation WebViewJavascriptBridge {
    WVJB_WEAK WVJB_WEBVIEW_TYPE* _webView;
    WVJB_WEAK id _webViewDelegate;
    long _uniqueId;
    WebViewJavascriptBridgeBase *_base;
}

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
// NOTE: The following allows the old support for WebView (macOS 10.3-10.14 - now
// deprecated), but not support UIWebView (iOS 2.0-12.0 - now deprecated).
// We do NOT want to support UIWebView on iOS, as Apple is warning developers of
// UIWebView API usage when submitting an app to the AppStore.  The thought is that
// this will soon be an error with iOS uploads in our near future.
#if defined WVJB_PLATFORM_OSX
    if ([webView isKindOfClass:[WVJB_WEBVIEW_TYPE class]]) {
        WebViewJavascriptBridge* bridge = [[self alloc] init];
        [bridge _platformSpecificSetup:webView];
        return bridge;
    }
#endif
    [NSException raise:@"BadWebViewType" format:@"Unknown web view type."];
    return nil;
}

- (void)setWebViewDelegate:(id)webViewDelegate {
    _webViewDelegate = webViewDelegate;
}

- (void)send:(id)data {
    [self send:data responseCallback:nil];
}

- (void)send:(id)data responseCallback:(WVJBResponseCallback)responseCallback {
    [_base sendData:data responseCallback:responseCallback handlerName:nil];
}

- (void)callHandler:(NSString *)handlerName {
    [self callHandler:handlerName data:nil responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    [self callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback {
    [_base sendData:data responseCallback:responseCallback handlerName:handlerName];
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    _base.messageHandlers[handlerName] = [handler copy];
}

- (void)removeHandler:(NSString *)handlerName {
    [_base.messageHandlers removeObjectForKey:handlerName];
}

- (void)disableJavscriptAlertBoxSafetyTimeout {
    [_base disableJavscriptAlertBoxSafetyTimeout];
}


/* Platform agnostic internals
 *****************************/

- (void)dealloc {
    #if defined WVJB_PLATFORM_OSX
        [self _platformSpecificDealloc];
    #endif
    _base = nil;
    _webView = nil;
    _webViewDelegate = nil;
}

- (NSString*) _evaluateJavascript:(NSString*)javascriptCommand {
#if defined WVJB_PLATFORM_OSX
    return [_webView stringByEvaluatingJavaScriptFromString:javascriptCommand];
#else
    // Respond with nothing on iOS, because this method isn't able to be used.
    return [[NSString alloc] init];
#endif
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

- (void) _platformSpecificDealloc {
    _webView.policyDelegate = nil;
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    if (webView != _webView) { return; }
    
    NSURL *url = [request URL];
    if ([_base isWebViewJavascriptBridgeURL:url]) {
        if ([_base isBridgeLoadedURL:url]) {
            [_base injectJavascriptFile];
        } else if ([_base isQueueMessageURL:url]) {
            NSString *messageQueueString = [self _evaluateJavascript:[_base webViewJavascriptFetchQueyCommand]];
            [_base flushMessageQueue:messageQueueString];
        } else {
            [_base logUnkownMessage:url];
        }
        [listener ignore];
    } else if (_webViewDelegate && [_webViewDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:request:frame:decisionListener:)]) {
        [_webViewDelegate webView:webView decidePolicyForNavigationAction:actionInformation request:request frame:frame decisionListener:listener];
    } else {
        [listener use];
    }
}



#elif defined WVJB_PLATFORM_IOS
/* Platform specific internals: iOS
 **********************************/
/* REMOVED, since UIVebView is no longer supported by Apple. */
#endif


@end
