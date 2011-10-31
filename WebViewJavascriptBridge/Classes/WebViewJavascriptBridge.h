#import <Foundation/Foundation.h>

@protocol WebViewJavascriptBridgeDelegate <NSObject>

- (void) handleMessage:(NSString*) message fromWebView: (UIWebView *)theWebView;

@end

@interface WebViewJavascriptBridge : NSObject <UIWebViewDelegate> {
    id <WebViewJavascriptBridgeDelegate> _delegate;
    NSMutableArray *_startupMessageQueue;
}

/** Delegate to receive messages from javascript. */
@property (readwrite, assign) id <WebViewJavascriptBridgeDelegate> delegate;

/** Creates & returns new autoreleased javascript Bridge with no delegate set. */
+ (id) javascriptBridge;

/** Sends message to given webView. You need to integrate javascript bridge into 
 * this view before by calling WebViewJavascriptBridge#webViewDidFinishLoad: with that view. 
 *
 * You can call this method before calling webViewDidFinishLoad: , than all messages
 * will be accumulated in _startupMessageQueue & sended to webView, provided by first
 * webViewDidFinishLoad: call.
 */
- (void) sendMessage:(NSString*) message toWebView:(UIWebView *) theWebView;

@end
