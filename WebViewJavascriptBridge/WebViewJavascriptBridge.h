#import <UIKit/UIKit.h>

typedef void (^WVJBCallback)(id data);
typedef void (^WVJBHandler)(id data, WVJBCallback callback);

@class WebViewJavascriptBridge;

@interface WebViewJavascriptBridge : NSObject <UIWebViewDelegate>

+ (id)javascriptBridgeForWebView:(UIWebView*)webView handler:(WVJBHandler)handler;
+ (id)javascriptBridgeForWebView:(UIWebView*)webView handler:(WVJBHandler)handler webViewDelegate:(id <UIWebViewDelegate>)webViewDelegate;

- (void)send:(id)message;
- (void)send:(id)message responseCallback:(WVJBCallback)responseCallback;

- (void)registerHandler:(NSString*)handlerName callback:(WVJBHandler)handler;

- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBCallback)responseCallback;

@end
