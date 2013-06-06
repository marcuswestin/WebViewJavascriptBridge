#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridgeAbstract.h"

@interface WebViewJavascriptBridge : WebViewJavascriptBridgeAbstract

@property (nonatomic, weak) WebView *webView;
@property (nonatomic, weak) id webViewDelegate;

+ (id)bridgeForWebView:(WebView*)webView handler:(WVJBHandler)handler;
+ (id)bridgeForWebView:(WebView*)webView webViewDelegate:(id)webViewDelegate handler:(WVJBHandler)handler;

@end
