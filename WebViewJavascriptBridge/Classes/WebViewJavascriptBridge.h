#import <Foundation/Foundation.h>

@protocol WebViewJavascriptBridgeDelegate <NSObject>

- (void) handleMessage:(NSString*) message;

@end

@interface WebViewJavascriptBridge : NSObject <UIWebViewDelegate> {
    id <WebViewJavascriptBridgeDelegate> delegate;
    NSString* secret;
}

@property (nonatomic, strong) NSString* secret;
@property (nonatomic, strong) id <WebViewJavascriptBridgeDelegate> delegate;
@property (nonatomic, retain) UIWebView* webView;
@property (nonatomic, strong) NSMutableArray* startupMessageQueue;

+ (id) createWithDelegate:(id <WebViewJavascriptBridgeDelegate>) delegate;

- (void) sendMessage:(NSString*) message;

- (void) _flushMessageQueue;
- (void) _doSendMessage:(NSString*)message;

@end
