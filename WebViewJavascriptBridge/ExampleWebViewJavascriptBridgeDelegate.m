//
//  ExampleWebViewJavascriptBridgeDelegate.m
//  WebViewJavascriptBridge
//
//  Created by John Marcus Westin on 8/27/11.
//  Copyright (c) 2011 Clover. All rights reserved.
//

#import "ExampleWebViewJavascriptBridgeDelegate.h"

@implementation ExampleWebViewJavascriptBridgeDelegate

- (void) handleMessage:(NSString *)message {
    NSLog(@"ExampleWebViewJavascriptBridgeDelegate received message: %@", message);
}

@end
