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
    
    
    // Load Page
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [[_webView mainFrame] loadHTMLString:html baseURL:nil];
}


- (void)_configureWKWebview {
    
    // Load Page
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [_WKWebView loadHTMLString:html baseURL:nil];
    
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
    
    // WKWebView
    _WKWebView = [[WKWebView alloc] initWithFrame:contentView.frame];
    [_WKWebView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
    
    // Tabs
    NSTabView *tabView = [[NSTabView alloc]
                           initWithFrame:contentView.frame];
    [contentView addSubview:tabView];
    
    NSTabViewItem *tab1 = [[NSTabViewItem alloc]
                            initWithIdentifier:@"tab1"];
    [tab1 setLabel:@"WebView"];
    [tabView addTabViewItem:tab1];
    
    NSTabViewItem *tab2 = [[NSTabViewItem alloc]
                           initWithIdentifier:@"tab2"];
    [tab2 setLabel:@"WKWebView"];
    [tabView addTabViewItem:tab2];
    
    // Initialize each tab
    [tab1 setView:_webView];
    [tab2 setView:_WKWebView];
}


@end
