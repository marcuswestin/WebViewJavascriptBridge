//
//  BridgeTests.m
//  WKWebViewJavascriptBridge
//
//  Created by Pieter De Baets on 18/04/2015.
//  Copyright (c) 2015 marcuswestin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WebViewJavascriptBridge.h"
#import "WKWebViewJavascriptBridge.h"
#import "AppDelegate.h"

static NSString *const echoHandler = @"echoHandler";

@interface BridgeTests : XCTestCase

@end

@implementation BridgeTests {
    UIWebView *_uiWebView;
    WKWebView *_wkWebView;
}

- (void)setUp {
    [super setUp];
    
    UIViewController *rootVC = [[(AppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController];
    _uiWebView = [[UIWebView alloc] initWithFrame:rootVC.view.bounds];
    CGRect wkFrame = _uiWebView.frame;
    wkFrame.origin.y += _uiWebView.frame.size.height;
    _wkWebView = [[WKWebView alloc] initWithFrame:wkFrame];
    [rootVC.view addSubview:_wkWebView];
}

- (void)tearDown {
    [super tearDown];
    [_uiWebView removeFromSuperview];
    [_wkWebView removeFromSuperview];
}

static void loadEchoSample(id webView) {
    NSURLRequest *request = [NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:@"echo" withExtension:@"html"]];
    [(UIWebView*)webView loadRequest:request];
}

const NSTimeInterval timeoutSec = 100;

- (void)testInitialization {
    [self classSpecificTestInitialization:[WebViewJavascriptBridge class] webView:_uiWebView];
    [self classSpecificTestInitialization:[WKWebViewJavascriptBridge class] webView:_wkWebView];
    [self waitForExpectationsWithTimeout:timeoutSec handler:NULL];
}
- (void)classSpecificTestInitialization:(Class)cls webView:(id)webView {
    XCTestExpectation *startup = [self expectationWithDescription:@"Startup completed"];
    WebViewJavascriptBridge *bridge = [self bridgeForCls:cls webView:webView];
    [bridge registerHandler:@"Greet" handler:^(id data, WVJBResponseCallback responseCallback) {
        XCTAssertEqualObjects(data, @"Hello world");
        [startup fulfill];
    }];
    XCTAssertNotNil(bridge);
    
    loadEchoSample(webView);
}

- (void)testEchoHandler {
    [self classSpecificTestEchoHandler:[WebViewJavascriptBridge class] webView:_uiWebView];
    [self classSpecificTestEchoHandler:[WKWebViewJavascriptBridge class] webView:_wkWebView];
    [self waitForExpectationsWithTimeout:timeoutSec handler:NULL];
}
- (void)classSpecificTestEchoHandler:(Class)cls webView:(id)webView {
    WebViewJavascriptBridge *bridge = [self bridgeForCls:cls webView:webView];
    
    XCTestExpectation *callbackInvocked = [self expectationWithDescription:@"Callback invoked"];
    [bridge callHandler:echoHandler data:@"testEchoHandler" responseCallback:^(id responseData) {
        XCTAssertEqualObjects(responseData, @"testEchoHandler");
        [callbackInvocked fulfill];
    }];
    
    loadEchoSample(webView);
}

- (void)testEchoHandlerAfterSetup {
    [self classSpecificTestEchoHandlerAfterSetup:[WebViewJavascriptBridge class] webView:_uiWebView];
    [self classSpecificTestEchoHandlerAfterSetup:[WKWebViewJavascriptBridge class] webView:_wkWebView];
    [self waitForExpectationsWithTimeout:timeoutSec handler:NULL];
}
- (void)classSpecificTestEchoHandlerAfterSetup:(Class)cls webView:(id)webView {
    WebViewJavascriptBridge *bridge = [self bridgeForCls:cls webView:webView];
    
    XCTestExpectation *callbackInvocked = [self expectationWithDescription:@"Callback invoked"];
    loadEchoSample(webView);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 150 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        [bridge callHandler:echoHandler data:@"testEchoHandler" responseCallback:^(id responseData) {
            XCTAssertEqualObjects(responseData, @"testEchoHandler");
            [callbackInvocked fulfill];
        }];
    });
}

- (void)testObjectEncoding {
    [self classSpecificTestObjectEncoding:[WebViewJavascriptBridge class] webView:_uiWebView];
    [self classSpecificTestObjectEncoding:[WKWebViewJavascriptBridge class] webView:_wkWebView];
    [self waitForExpectationsWithTimeout:timeoutSec handler:NULL];
}
- (void)classSpecificTestObjectEncoding:(Class)cls webView:(id)webView {
    WebViewJavascriptBridge *bridge = [self bridgeForCls:cls webView:webView];
    
    void (^echoObject)(id) = ^void(id object) {
        XCTestExpectation *callbackInvocked = [self expectationWithDescription:@"Callback invoked"];
        [bridge callHandler:echoHandler data:object responseCallback:^(id responseData) {
            XCTAssertEqualObjects(responseData, object);
            [callbackInvocked fulfill];
        }];
    };
    
    echoObject(@"A string sent over the wire");
    echoObject(@"A string with '\"'/\\");
    echoObject(@[ @1, @2, @3 ]);
    echoObject(@{ @"a" : @1, @"b" : @2 });
    
    loadEchoSample(webView);
}

- (void)testJavascriptReceiveResponse {
    [self classSpecificTestJavascriptReceiveResponse:[WebViewJavascriptBridge class] webView:_uiWebView];
    [self classSpecificTestJavascriptReceiveResponse:[WKWebViewJavascriptBridge class] webView:_wkWebView];
    [self waitForExpectationsWithTimeout:timeoutSec handler:NULL];
}
- (void)classSpecificTestJavascriptReceiveResponse:(Class)cls webView:(id)webView {
    WebViewJavascriptBridge *bridge = [self bridgeForCls:cls webView:webView];
    loadEchoSample(webView);
    XCTestExpectation *callbackInvocked = [self expectationWithDescription:@"Callback invoked"];
    [bridge registerHandler:@"objcEchoToJs" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(data);
    }];
    [bridge callHandler:@"jsRcvResponseTest" data:nil responseCallback:^(id responseData) {
        XCTAssertEqualObjects(responseData, @"Response from JS");
        [callbackInvocked fulfill];
    }];
}

- (void)testJavascriptReceiveResponseWithoutSafetyTimeout {
    [self classSpecificTestJavascriptReceiveResponseWithoutSafetyTimeout:[WebViewJavascriptBridge class] webView:_uiWebView];
    [self classSpecificTestJavascriptReceiveResponseWithoutSafetyTimeout:[WKWebViewJavascriptBridge class] webView:_wkWebView];
    [self waitForExpectationsWithTimeout:timeoutSec handler:NULL];
}
- (void)classSpecificTestJavascriptReceiveResponseWithoutSafetyTimeout:(Class)cls webView:(id)webView {
    WebViewJavascriptBridge *bridge = [self bridgeForCls:cls webView:webView];
    [bridge disableJavscriptAlertBoxSafetyTimeout];
    loadEchoSample(webView);
    XCTestExpectation *callbackInvocked = [self expectationWithDescription:@"Callback invoked"];
    [bridge registerHandler:@"objcEchoToJs" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(data);
    }];
    [bridge callHandler:@"jsRcvResponseTest" data:nil responseCallback:^(id responseData) {
        XCTAssertEqualObjects(responseData, @"Response from JS");
        [callbackInvocked fulfill];
    }];
}


- (WebViewJavascriptBridge*)bridgeForCls:(Class)cls webView:(id)webView {
    if (cls == [WebViewJavascriptBridge class]) {
        return [WebViewJavascriptBridge bridgeForWebView:webView];
    } else {
        return (WebViewJavascriptBridge*)[WKWebViewJavascriptBridge bridgeForWebView:_wkWebView];
    }
}
@end
