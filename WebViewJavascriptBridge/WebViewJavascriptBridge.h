#import <UIKit/UIKit.h>

@class WebViewJavascriptBridge;

@protocol WebViewJavascriptBridgeDelegate <UIWebViewDelegate>

- (void)javascriptBridge:(WebViewJavascriptBridge *)bridge receivedMessage:(NSString *)message fromWebView:(UIWebView *)webView;

@end

@interface WebViewJavascriptBridge : NSObject <UIWebViewDelegate>

@property (nonatomic, assign) IBOutlet id <WebViewJavascriptBridgeDelegate> delegate;

/* Create a javascript bridge with the given delegate for handling messages */
+ (id)javascriptBridgeWithDelegate:(id <WebViewJavascriptBridgeDelegate>)delegate;

/* Send a message to the web view. Make sure that this javascript bridge is the delegate
 * of the webview before calling this method (see ExampleAppDelegate.m) */
- (void)sendMessage:(NSString *)message toWebView:(UIWebView *)webView;

/* Reset startup messaging queue */
- (void)resetQueue;

@end
