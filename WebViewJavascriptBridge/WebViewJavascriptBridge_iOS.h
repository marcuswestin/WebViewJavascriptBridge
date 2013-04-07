//
//  WebViewJavascriptBridge+iOS.h
//  ExampleApp-iOS
//
//  Created by Antoine Lagadec on 07/04/13.
//  Copyright (c) 2013 Marcus Westin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewJavascriptBridgeAbstract.h"

@interface WebViewJavascriptBridge : WebViewJavascriptBridgeAbstract <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) id <UIWebViewDelegate> webViewDelegate;

+ (id)bridgeForWebView:(UIWebView*)webView handler:(WVJBHandler)handler;
+ (id)bridgeForWebView:(UIWebView*)webView webViewDelegate:(id <UIWebViewDelegate>)webViewDelegate handler:(WVJBHandler)handler;

@end
