//
//  BridgeTests.m
//  WKWebViewJavascriptBridge
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
@interface TestWebPageLoadDelegate : NSObject<UIWebViewDelegate, WKNavigationDelegate>
@property XCTestExpectation* expectation;
@end

@implementation BridgeTests {
    UIWebView *_uiWebView;
    WKWebView *_wkWebView;
    NSMutableArray* _retains;
}

- (void)setUp {
    [super setUp];
    
    UIViewController *rootVC = [[(AppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController];
    CGRect frame = rootVC.view.bounds;
    frame.size.height /= 2;
    _uiWebView = [[UIWebView alloc] initWithFrame:frame];
    _uiWebView.backgroundColor = [UIColor blueColor];
    [rootVC.view addSubview:_uiWebView];
    frame.origin.y += frame.size.height;
    _wkWebView = [[WKWebView alloc] initWithFrame:frame];
    _wkWebView.backgroundColor = [UIColor redColor];
    [rootVC.view addSubview:_wkWebView];
    
    _retains = [NSMutableArray array];
}

- (void)tearDown {
    [super tearDown];
    [_uiWebView removeFromSuperview];
    [_wkWebView removeFromSuperview];
}

- (WebViewJavascriptBridge*)bridgeForWebView:(id)webView {
    WebViewJavascriptBridge* bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
    [_retains addObject:bridge];
    return bridge;
}

static void loadEchoSample(id webView) {
    NSURLRequest *request = [NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:@"echo" withExtension:@"html"]];
    [(UIWebView*)webView loadRequest:request];
}

const NSTimeInterval timeoutSec = 5;

- (void)testEchoHandler {
    [self classSpecificTestEchoHandler:_uiWebView];
    [self classSpecificTestEchoHandler:_wkWebView];
    [self waitForExpectationsWithTimeout:timeoutSec handler:NULL];
}
- (void)classSpecificTestEchoHandler:(id)webView {
    WebViewJavascriptBridge *bridge = [self bridgeForWebView:webView];
    
    XCTestExpectation *callbackInvocked = [self expectationWithDescription:@"Callback invoked"];
    [bridge callHandler:echoHandler data:@"testEchoHandler" responseCallback:^(id responseData) {
        XCTAssertEqualObjects(responseData, @"testEchoHandler");
        [callbackInvocked fulfill];
    }];
    
    loadEchoSample(webView);
}

- (void)testEchoHandlerAfterSetup {
    [self classSpecificTestEchoHandlerAfterSetup:_uiWebView];
    [self classSpecificTestEchoHandlerAfterSetup:_wkWebView];
    [self waitForExpectationsWithTimeout:timeoutSec handler:NULL];
}
- (void)classSpecificTestEchoHandlerAfterSetup:(id)webView {
    WebViewJavascriptBridge *bridge = [self bridgeForWebView:webView];
    
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
    [self classSpecificTestObjectEncoding:_uiWebView];
    [self classSpecificTestObjectEncoding:_wkWebView];
    [self waitForExpectationsWithTimeout:timeoutSec handler:NULL];
}
- (void)classSpecificTestObjectEncoding:(id)webView {
    WebViewJavascriptBridge *bridge = [self bridgeForWebView:webView];
    
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
    [self classSpecificTestJavascriptReceiveResponse:_uiWebView];
    [self classSpecificTestJavascriptReceiveResponse:_wkWebView];
    [self waitForExpectationsWithTimeout:timeoutSec handler:NULL];
}
- (void)classSpecificTestJavascriptReceiveResponse:(id)webView {
    WebViewJavascriptBridge *bridge = [self bridgeForWebView:webView];
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
    [self classSpecificTestJavascriptReceiveResponseWithoutSafetyTimeout:_uiWebView];
    [self classSpecificTestJavascriptReceiveResponseWithoutSafetyTimeout:_wkWebView];
    [self waitForExpectationsWithTimeout:timeoutSec handler:NULL];
}
- (void)classSpecificTestJavascriptReceiveResponseWithoutSafetyTimeout:(id)webView {
    WebViewJavascriptBridge *bridge = [self bridgeForWebView:webView];
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

- (void)testWebpageLoad {
    [self classSpecificTestWebpageLoad:_uiWebView];
    [self classSpecificTestWebpageLoad:_wkWebView];
    [self waitForExpectationsWithTimeout:timeoutSec handler:NULL];
}
- (void)classSpecificTestWebpageLoad:(id)webView {
    WebViewJavascriptBridge* bridge = [self bridgeForWebView:webView];
    TestWebPageLoadDelegate* delegate = [TestWebPageLoadDelegate new];
    delegate.expectation = [self expectationWithDescription:@"Webpage loaded"];
    [_retains addObject:delegate];
    [bridge setWebViewDelegate:delegate];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://example.com"]];
    [(UIWebView*)webView loadRequest:request];
}
@end

@implementation TestWebPageLoadDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.expectation fulfill];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.expectation fulfill];
}
@end
