#import "ExampleWebViewJavascriptBridgeDelegate.h"

@implementation ExampleWebViewJavascriptBridgeDelegate

- (void) handleMessage:(NSString *)message {
    NSLog(@"ExampleWebViewJavascriptBridgeDelegate received message: %@", message);
}

@end
