#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridgeAbstract.h"

@interface WebViewJavascriptBridge : WebViewJavascriptBridgeAbstract

@property (nonatomic, strong) WebView *webView;
@property (nonatomic, strong) id webViewDelegate;

+ (id)bridgeForWebView:(WebView*)webView handler:(WVJBHandler)handler;
+ (id)bridgeForWebView:(WebView*)webView webViewDelegate:(id)webViewDelegate handler:(WVJBHandler)handler;

@end
