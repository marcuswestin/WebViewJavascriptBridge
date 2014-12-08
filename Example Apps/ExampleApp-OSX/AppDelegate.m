//
//  AppDelegate.m
//  ExampleApp-OSX
//
//  Created by Marcus Westin on 6/8/13.
//  Copyright (c) 2013 Marcus Westin. All rights reserved.
//

#import "AppDelegate.h"
#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridge.h"
#import "WKWebViewJavascriptBridge.h"

@implementation AppDelegate {
    WebView* _webView;
    WKWebView *_WKWebView;
    WebViewJavascriptBridge* _bridge;
    WKWebViewJavascriptBridge* _WKBridge;
    NSView* _WKWebViewWrapper;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self _createViews];
    [self _configureWebview];
    [self _configureWKWebview];
}

- (void)_configureWebview {
    // Create Bridge
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
    }];
    
    [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];
    
    [_bridge send:@"A string sent from ObjC before Webview has loaded." responseCallback:^(id responseData) {
        NSLog(@"objc got response! %@", responseData);
    }];
    
    [_bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];

    // Create Buttons
    NSButton *messageButton = [[NSButton alloc] initWithFrame:NSMakeRect(5, 0, 120, 40)];
    [messageButton setTitle:@"Send message"];
    [messageButton setBezelStyle:NSRoundedBezelStyle];
    [messageButton setTarget:self];
    [messageButton setAction:@selector(_sendMessage)];
    [_webView addSubview:messageButton];
    
    NSButton *callbackButton = [[NSButton alloc] initWithFrame:NSMakeRect(120, 0, 120, 40)];
    [callbackButton setTitle:@"Call handler"];
    [callbackButton setBezelStyle:NSRoundedBezelStyle];
    [callbackButton setTarget:self];
    [callbackButton setAction:@selector(_callHandler)];
    [_webView addSubview:callbackButton];
    
    NSButton *webViewToggleButton = [[NSButton alloc] initWithFrame:NSMakeRect(235, 0, 180, 40)];
    [webViewToggleButton setTitle:@"Switch to WKWebView"];
    [webViewToggleButton setBezelStyle:NSRoundedBezelStyle];
    [webViewToggleButton setTarget:self];
    [webViewToggleButton setAction:@selector(_toggleExample)];
    [_webView addSubview:webViewToggleButton];
    
    
    // Load Page
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [[_webView mainFrame] loadHTMLString:html baseURL:nil];
}


- (void)_configureWKWebview {
    // Create Bridge
    _WKBridge = [WKWebViewJavascriptBridge bridgeForWebView:_WKWebView handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
    }];
    
    [_WKBridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];
    
    [_WKBridge send:@"A string sent from ObjC before Webview has loaded." responseCallback:^(id responseData) {
        NSLog(@"objc got response! %@", responseData);
    }];
    
    [_WKBridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
    
    // Create Buttons
    NSButton *messageButton = [[NSButton alloc] initWithFrame:NSMakeRect(5, 0, 120, 40)];
    [messageButton setTitle:@"Send message"];
    [messageButton setBezelStyle:NSRoundedBezelStyle];
    [messageButton setTarget:self];
    [messageButton setAction:@selector(_WKSendMessage)];
    [_WKWebView addSubview:messageButton];
    
    NSButton *callbackButton = [[NSButton alloc] initWithFrame:NSMakeRect(120, 0, 120, 40)];
    [callbackButton setTitle:@"Call handler"];
    [callbackButton setBezelStyle:NSRoundedBezelStyle];
    [callbackButton setTarget:self];
    [callbackButton setAction:@selector(_WKCallHandler)];
    [_WKWebView addSubview:callbackButton];
    
    NSButton *webViewToggleButton = [[NSButton alloc] initWithFrame:NSMakeRect(235, 0, 180, 40)];
    [webViewToggleButton setTitle:@"Switch to WebView"];
    [webViewToggleButton setBezelStyle:NSRoundedBezelStyle];
    [webViewToggleButton setTarget:self];
    [webViewToggleButton setAction:@selector(_toggleExample)];
    [_WKWebView addSubview:webViewToggleButton];
    
    // Load Page
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [_WKWebView loadHTMLString:html baseURL:nil];
}

-(void)_toggleExample {
    _WKWebView.hidden = !_WKWebView.isHidden;
    _webView.hidden = !_webView.isHidden;
}

- (void)_sendMessage {
    [_bridge send:@"A string sent from ObjC to JS" responseCallback:^(id response) {
        NSLog(@"sendMessage got response: %@", response);
    }];
}

- (void)_callHandler {
    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
}

- (void)_WKSendMessage {
    [_WKBridge send:@"A string sent from ObjC to JS" responseCallback:^(id response) {
        NSLog(@"sendMessage got response: %@", response);
    }];
}

- (void)_WKCallHandler {
    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
    [_WKBridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
}

- (void)_createViews {
    NSView* contentView = _window.contentView;
    // WebView
    _webView = [[WebView alloc] initWithFrame:contentView.frame];
    [_webView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
    _webView.hidden = YES;
    
    // WKWebView
    _WKWebView = [[WKWebView alloc] initWithFrame:contentView.frame];
    [_WKWebView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
    
    [contentView addSubview:_WKWebView];
    [contentView addSubview:_webView];
}


@end
