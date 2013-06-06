#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridgeAbstract.h"

@interface WebViewJavascriptBridge : WebViewJavascriptBridgeAbstract

@property (nonatomic, strong) WebView *webView;
@property (nonatomic, strong) id webViewDelegate;

+ (instancetype)bridgeForWebView:(WebView*)webView handler:(WVJBHandler)handler;
+ (instancetype)bridgeForWebView:(WebView*)webView webViewDelegate:(id)webViewDelegate handler:(WVJBHandler)handler;

@end
