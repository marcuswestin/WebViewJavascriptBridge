//
//  ExampleSwiftApp_iOSTests.swift
//  ExampleSwiftApp-iOSTests
//
//  Created by John Marcus Westin on 12/27/16.
//  Copyright © 2016 Marcus Westin. All rights reserved.
//

import XCTest
import WebKit

import WebViewJavascriptBridge
@testable import ExampleSwiftApp_iOS

let timeout: Double = 3

class ExampleSwiftApp_iOSTests: XCTestCase {
    var uiWebView: UIWebView = UIWebView.init()
    var wkWebView: WKWebView = WKWebView.init()
    var bridgeRefs: NSMutableArray = []
    
    override func setUp() {
        super.setUp()
        
        let rootVC = (UIApplication.shared.delegate as! AppDelegate).window!.rootViewController!
        var frame = rootVC.view.bounds
        frame.size.height /= 2
        
        uiWebView = UIWebView.init(frame: frame)
        uiWebView.backgroundColor = UIColor.blue
        rootVC.view.addSubview(uiWebView)
        
        frame.origin.y += frame.size.height
        wkWebView = WKWebView.init(frame: frame)
        wkWebView.backgroundColor = UIColor.red
        rootVC.view.addSubview(wkWebView)
        
        bridgeRefs = NSMutableArray.init()
    }
    
    override func tearDown() {
        super.tearDown()
        uiWebView.removeFromSuperview()
        wkWebView.removeFromSuperview()
    }
    
    func bridgeForWebView(_ webView: Any) -> WebViewJavascriptBridge {
        let bridge = WebViewJavascriptBridge.init(webView)!
        bridgeRefs.add(bridge)
        return bridge
    }
    
    func loadEchoSample(_ webView: Any) {
        let request = URLRequest.init(url: Bundle.main.url(forResource: "echo", withExtension: "html")!)
        if webView is UIWebView {
            (webView as! UIWebView).loadRequest(request)
        } else {
            (webView as! WKWebView).load(request)
        }
    }
    
    func testSetup() {
        _testSetup(webView: uiWebView)
        _testSetup(webView: wkWebView)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    func _testSetup(webView: Any) {
        let setup = self.expectation(description: "Setup completed")
        let bridge = self.bridgeForWebView(webView: webView)
        bridge.registerHandler("Greet") { (data, responseCallback) in
            XCTAssertEqual(data as! String, "Hello world")
            setup.fulfill()
        }
        XCTAssertNotNil(bridge)
        self.loadEchoSample(webView)
    }
    
    
    func testEchoHandler() {
        _testEchoHandler(uiWebView)
        _testEchoHandler(wkWebView)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    func _testEchoHandler(_ webView: Any) {
        let bridge = bridgeForWebView(webView)
        
        let callbackInvoked = expectation(description: "Callback invoked")
        bridge.callHandler("echoHandler", data:"testEchoHandler") { (responseData) in
            XCTAssertEqual(responseData as! String, "testEchoHandler");
            callbackInvoked.fulfill()
        };
        
        loadEchoSample(webView);
    }
    
    func testEchoHandlerAfterSetup() {
        _testEchoHandlerAfterSetup(uiWebView)
        _testEchoHandlerAfterSetup(wkWebView)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    func _testEchoHandlerAfterSetup(_ webView: Any) {
        let bridge = bridgeForWebView(webView)
        
        let callbackInvoked = expectation(description: "Callback invoked")
        loadEchoSample(webView);
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.150) {
            bridge.callHandler("echoHandler", data:"testEchoHandler") { (responseData) in
                XCTAssertEqual(responseData as! String, "testEchoHandler")
                callbackInvoked.fulfill()
            }
        }
    }
    
    func testObjectEncoding() {
        _testObjectEncoding(uiWebView)
        _testObjectEncoding(wkWebView)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    func _testObjectEncoding(_ webView: Any) {
        let bridge = bridgeForWebView(webView)
        
        func echoObject(_ object: Any) {
            let callbackInvoked = expectation(description: "Callback invoked")
            bridge.callHandler("echoHandler", data:object) { (responseData) in
                if (object is NSDictionary) {
                    XCTAssertEqual(responseData as! NSDictionary, object as! NSDictionary)
                } else if (object is NSArray) {
                    XCTAssertEqual(responseData as! NSArray, object as! NSArray)
                }
                callbackInvoked.fulfill()
            }
        }

        echoObject("A string sent over the wire");
        echoObject("A string with '\"'/\\");
        echoObject([1, 2, 3]);
        echoObject(["a":1, "b":2]);
        
        loadEchoSample(webView);
    }
    
    func testJavascriptReceiveResponse() {
        _testJavascriptReceiveResponse(uiWebView)
        _testJavascriptReceiveResponse(wkWebView)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    func _testJavascriptReceiveResponse(_ webView: Any) {
        let bridge = bridgeForWebView(webView)
        loadEchoSample(webView);
        let callbackInvoked = expectation(description: "Callback invoked")
        bridge.registerHandler("objcEchoToJs") { (data, responseCallback) in
            XCTAssertEqual(data as! NSDictionary, ["foo":"bar"]);
            responseCallback!(data)
        }
        bridge.callHandler("jsRcvResponseTest", data:nil) { (responseData) in
            XCTAssertEqual(responseData as! String, "Response from JS");
            callbackInvoked.fulfill()
        }
    }
    
    func testJavascriptReceiveResponseWithoutSafetyTimeout() {
        _testJavascriptReceiveResponseWithoutSafetyTimeout(uiWebView)
        _testJavascriptReceiveResponseWithoutSafetyTimeout(wkWebView)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    func _testJavascriptReceiveResponseWithoutSafetyTimeout(_ webView: Any) {
        let bridge = bridgeForWebView(webView)
        bridge.disableJavscriptAlertBoxSafetyTimeout()
        loadEchoSample(webView);
        let callbackInvoked = expectation(description: "Callback invoked")
        bridge.registerHandler("objcEchoToJs") { (data, responseCallback) in
            XCTAssertEqual(data as! NSDictionary, ["foo":"bar"]);
            responseCallback!(data);
        }
        bridge.callHandler("jsRcvResponseTest", data:nil) { (responseData) in
            XCTAssertEqual(responseData as! String, "Response from JS");
            callbackInvoked.fulfill()
        }
    }
    
    func testRemoveHandler() {
        _testRemoveHandler(uiWebView)
        _testRemoveHandler(wkWebView)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    func _testRemoveHandler(_ webView: Any) {
        loadEchoSample(webView);
        let bridge = bridgeForWebView(webView)
        let callbackNotInvoked = expectation(description: "Callback invoked")
        var count = 0
        bridge.registerHandler("objcEchoToJs") { (data, callback) in
            count += 1
            callback!(data)
        }
        bridge.callHandler("jsRcvResponseTest", data:nil) { (responseData) in
            XCTAssertEqual(responseData as! String, "Response from JS");
            bridge.removeHandler("objcEchoToJs")
            bridge.callHandler("jsRcvResponseTest", data:nil) { (responseData) in
                // Since we have removed the "objcEchoToJs" handler, and since the
                // echo.html javascript won't call the response callback until it has
                // received a response from "objcEchoToJs", we should never get here
                XCTAssert(false)
            }
            bridge.callHandler("echoHandler", data:nil ) { (responseData) in
                XCTAssertEqual(count, 1)
                callbackNotInvoked.fulfill()
            }
        }
    }
    
}
