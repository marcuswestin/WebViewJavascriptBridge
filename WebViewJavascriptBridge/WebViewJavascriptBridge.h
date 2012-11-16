#import <UIKit/UIKit.h>

@class WVJBResponse;
typedef void (^WVJBResponseCallback)(id error, id responseData);
typedef void (^WVJBHandler)(id data, WVJBResponse* response);

@interface WebViewJavascriptBridge : NSObject <UIWebViewDelegate>
+ (id)bridgeForWebView:(UIWebView*)webView handler:(WVJBHandler)handler;
+ (id)bridgeForWebView:(UIWebView*)webView webViewDelegate:(id <UIWebViewDelegate>)webViewDelegate handler:(WVJBHandler)handler;
+ (void)enableLogging;
- (void)send:(id)message;
- (void)send:(id)message responseCallback:(WVJBResponseCallback)responseCallback;
- (void)registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler;
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
- (void)reset;
@end

@interface WVJBResponse : NSObject
- (WVJBResponse*) initWithCallbackId:(NSString*)callbackId bridge:(WebViewJavascriptBridge*)bridge;
- (void) respondWith:(id)responseData;
- (void) respondWithError:(id)error;
@end
