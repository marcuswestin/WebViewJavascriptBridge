#import <UIKit/UIKit.h>

typedef void (^WVJBResponseCallback)(id responseData);
typedef void (^WVJBHandler)(id data, WVJBResponseCallback responseCallback);

@class WebViewJavascriptBridge;

@interface WebViewJavascriptBridge : NSObject <UIWebViewDelegate>

+ (id)javascriptBridgeForWebView:(UIWebView*)webView handler:(WVJBHandler)handler;
+ (id)javascriptBridgeForWebView:(UIWebView*)webView handler:(WVJBHandler)handler webViewDelegate:(id <UIWebViewDelegate>)webViewDelegate;

- (void)send:(id)message;
- (void)send:(id)message responseCallback:(WVJBResponseCallback)responseCallback;

- (void)registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler;

- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;

@end
