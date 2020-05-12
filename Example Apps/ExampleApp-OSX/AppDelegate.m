//
//  AppDelegate.m
//  ExampleApp-OSX
//
//  Created by Marcus Westin on 6/8/13.
//  Copyright (c) 2013 Marcus Westin. All rights reserved.
//

#import "AppDelegate.h"
#import <WebKit/WebKit.h>
#import "WKWebView+JavaScriptBridge.h"

@implementation AppDelegate {
    WKWebView *_WKWebView;
    NSView* _WKWebViewWrapper;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self _createViews];
    [self _configureWKWebview];
}

- (void)_configureWKWebview {
    // Create Bridge
    [WKWebView enableLogging:LogginglevelAll];
    [_WKWebView registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];
    
    // Create Buttons
    NSButton *callbackButton = [[NSButton alloc] initWithFrame:NSMakeRect(5, 0, 120, 40)];
    [callbackButton setTitle:@"Call handler"];
    [callbackButton setBezelStyle:NSRoundedBezelStyle];
    [callbackButton setTarget:self];
    [callbackButton setAction:@selector(_WKCallHandler)];
    [_WKWebView addSubview:callbackButton];
    
    
    // Load Page
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [_WKWebView loadHTMLString:html baseURL:baseURL];
}
- (void)_WKCallHandler {
    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
    [_WKWebView callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
}

- (void)_createViews {
    NSView* contentView = _window.contentView;
    // WKWebView
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    _WKWebView = [[WKWebView alloc] initWithFrame:contentView.frame configuration:config];
    [_WKWebView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
    
    [contentView addSubview:_WKWebView];
}


@end
