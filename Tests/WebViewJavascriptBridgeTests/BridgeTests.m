//
//  BridgeTests.m
//  WebViewJavascriptBridge
//
//  Created by Pieter De Baets on 18/04/2015.
//  Copyright (c) 2015 marcuswestin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WebViewJavascriptBridge.h"
#import "AppDelegate.h"

static NSString *const echoHandler = @"echoHandler";

@interface BridgeTests : XCTestCase

@end

@implementation BridgeTests {
  UIWebView *_webView;
}

- (void)setUp
{
  [super setUp];

  UIViewController *rootVC = [[(AppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController];
  _webView = [[UIWebView alloc] initWithFrame:rootVC.view.bounds];
  [rootVC.view addSubview:_webView];
}

- (void)tearDown
{
  [super tearDown];
  [_webView removeFromSuperview];
}

static void loadEchoSample(UIWebView *webView)
{
  NSURLRequest *request = [NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:@"echo" withExtension:@"html"]];
  [webView loadRequest:request];
}

- (void)testInitialization
{
  XCTestExpectation *startup = [self expectationWithDescription:@"Startup completed"];
    WebViewJavascriptBridge *bridge = [WebViewJavascriptBridge bridgeForWebView:_webView];
    [bridge registerHandler:@"Greet" handler:^(id data, WVJBResponseCallback responseCallback) {
        XCTAssertEqualObjects(data, @"Hello world");
        [startup fulfill];
    }];
  XCTAssertNotNil(bridge);

  loadEchoSample(_webView);
  [self waitForExpectationsWithTimeout:1 handler:NULL];
}

- (void)testEchoHandler
{
  WebViewJavascriptBridge *bridge = [WebViewJavascriptBridge bridgeForWebView:_webView];

  XCTestExpectation *callbackInvocked = [self expectationWithDescription:@"Callback invoked"];
  [bridge callHandler:echoHandler data:@"testEchoHandler" responseCallback:^(id responseData) {
    XCTAssertEqualObjects(responseData, @"testEchoHandler");
    [callbackInvocked fulfill];
  }];

  loadEchoSample(_webView);
  [self waitForExpectationsWithTimeout:1 handler:NULL];
}

- (void)testEchoHandlerAfterSetup
{
    WebViewJavascriptBridge *bridge = [WebViewJavascriptBridge bridgeForWebView:_webView];
    
    XCTestExpectation *callbackInvocked = [self expectationWithDescription:@"Callback invoked"];
    loadEchoSample(_webView);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 150 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        [bridge callHandler:echoHandler data:@"testEchoHandler" responseCallback:^(id responseData) {
            XCTAssertEqualObjects(responseData, @"testEchoHandler");
            [callbackInvocked fulfill];
        }];
    });
    [self waitForExpectationsWithTimeout:1 handler:NULL];
}

- (void)testObjectEncoding
{
  WebViewJavascriptBridge *bridge = [WebViewJavascriptBridge bridgeForWebView:_webView];

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

  loadEchoSample(_webView);
  [self waitForExpectationsWithTimeout:1 handler:NULL];
}

@end
