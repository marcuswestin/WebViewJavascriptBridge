#import <UIKit/UIKit.h>
#import "WebViewJavascriptBridge.h"
#import "ExampleWebViewJavascriptBridgeDelegate.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) WebViewJavascriptBridge *javascriptBridge;
@property (strong, nonatomic) ExampleWebViewJavascriptBridgeDelegate* javascriptBridgeDelegate;

- (void) loadExamplePage;

@end
