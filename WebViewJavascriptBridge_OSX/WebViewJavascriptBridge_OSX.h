//
//  WebViewJavascriptBridge+OSX.h
//  ExampleApp-OSX
//
//  Created by Antoine Lagadec on 07/04/13.
//  Copyright (c) 2013 Antoine Lagadec. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridgeAbstract.h"

@interface WebViewJavascriptBridge : WebViewJavascriptBridgeAbstract

@property (nonatomic, strong) WebView *webView;
@property (nonatomic, strong) id webViewDelegate;

+ (id)bridgeForWebView:(WebView*)webView handler:(WVJBHandler)handler;
+ (id)bridgeForWebView:(WebView*)webView webViewDelegate:(id)webViewDelegate handler:(WVJBHandler)handler;

@end
