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

@implementation AppDelegate {
    WebView* _webView;
    WebViewJavascriptBridge* _bridge;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self _createViews];
    [self _createBridge];
    [self _createObjcButtons];
    [self _loadPage];
}

- (void)_createBridge {
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
    
    [_bridge callHandler:@"testJavascriptHandler" data:[NSDictionary dictionaryWithObject:@"before ready" forKey:@"foo"]];
}

- (void)_createObjcButtons {
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
}

- (void)_sendMessage {
    [_bridge send:@"A string sent from ObjC to JS" responseCallback:^(id response) {
        NSLog(@"sendMessage got response: %@", response);
    }];
}

- (void)_callHandler {
    NSDictionary* data = [NSDictionary dictionaryWithObject:@"Hi there, JS!" forKey:@"greetingFromObjC"];
    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];    
}

- (void)_createViews {
    NSView* contentView = _window.contentView;
    _webView = [[WebView alloc] initWithFrame:contentView.frame];
    [_webView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
    [contentView addSubview:_webView];
}

- (void)_loadPage {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [[_webView mainFrame] loadHTMLString:html baseURL:nil];
}


@end
