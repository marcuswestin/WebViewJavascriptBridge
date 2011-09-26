#import <UIKit/UIKit.h>
#import "WebViewJavascriptBridge.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, WebViewJavascriptBridgeDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) WebViewJavascriptBridge *javascriptBridge;

- (void) loadExamplePage;

@end
