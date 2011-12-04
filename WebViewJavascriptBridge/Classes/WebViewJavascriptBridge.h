#import <UIKit/UIKit.h>

@class WebViewJavascriptBridge;

@protocol WebViewJavascriptBridgeDelegate <UIWebViewDelegate>

- (void)javascriptBridge:(WebViewJavascriptBridge *)bridge receivedMessage:(NSString *)message fromWebView:(UIWebView *)webView;

@end

@interface WebViewJavascriptBridge : NSObject <UIWebViewDelegate>

/** Delegate to receive messages from javascript. */
/** Defined as IBOutlet for Interface Builder assignment */
@property (nonatomic, assign) IBOutlet id <WebViewJavascriptBridgeDelegate> delegate;

/** Init with a predefined delegate */
- (id)initWithDelegate:(id <WebViewJavascriptBridgeDelegate>)delegate;

/** Convenience methods for obtaining a bridge */
+ (id)javascriptBridge;
+ (id)javascriptBridgeWithDelegate:(id <WebViewJavascriptBridgeDelegate>)delegate;

/** Sends message to given webView. You need to integrate javascript bridge into 
 * this view before by calling WebViewJavascriptBridge#webViewDidFinishLoad: with that view. 
 *
 * You can call this method before calling webViewDidFinishLoad: , then all messages
 * will be accumulated in _startupMessageQueue & sended to webView, provided by first
 * webViewDidFinishLoad: call.
 */
- (void)sendMessage:(NSString *)message toWebView:(UIWebView *)webView;

@end
