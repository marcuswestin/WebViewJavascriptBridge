//
//  WebViewJavascriptBridge.m
//  TestPod
//
//  Created by 侯森魁 on 2020/4/29.
//  Copyright © 2020 侯森魁. All rights reserved.
//

#import "WebViewJavascriptBridge.h"
#import "WebViewJavascriptLeakAvoider.h"
#define kBridgePrefix @"__bridge__"

@implementation WebViewJavascriptBridge  {
       WKWebView* _webView;
       long _uniqueId;
       WebViewJavascriptBridgeBase *_base;
       BOOL _showJSconsole;
       BOOL _enableLogging;
}

+ (instancetype)bridgeForWebView:(WKWebView*)webView
                   showJSconsole:(BOOL)show
                   enableLogging:(BOOL)enable {
    WebViewJavascriptBridge* bridge = [[self alloc] init];
    [bridge _setupInstance:webView showJSconsole:show enableLogging:enable];
    return bridge;
}

- (void)callHandler:(NSString *)handlerName {
    [self callHandler:handlerName data:nil responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    [self callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback {
    [_base sendData:data responseCallback:responseCallback handlerName:handlerName];
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    _base.messageHandlers[handlerName] = [handler copy];
}

- (void)removeHandler:(NSString *)handlerName {
    [_base.messageHandlers removeObjectForKey:handlerName];
}


- (void)_setupInstance:(WKWebView*)webView showJSconsole:(BOOL)show enableLogging:(BOOL)enable{
    _webView = webView;
    _base = [[WebViewJavascriptBridgeBase alloc] init];
    _base.delegate = self;
    _showJSconsole = show;
    _enableLogging = enable;

    [self addScriptMessageHandler];
    [self _injectJavascriptFile];
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString * body = (NSString * )message.body;
    if ([self _filterMessage:body]) {
        NSMutableString *mstr = [NSMutableString stringWithString:body];
        [mstr replaceOccurrencesOfString:kBridgePrefix withString:@"" options:0 range:NSMakeRange(0, 10)];
        [_base flushMessageQueue:mstr];
    }
}
- (void)_injectJavascriptFile {
    NSString *bridge_js = WebViewJavascriptBridge_js();
    //injected the method when H5 starts to create the DOM tree
    WKUserScript * bridge_userScript = [[WKUserScript alloc]initWithSource:bridge_js injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [_webView.configuration.userContentController addUserScript:bridge_userScript];
    if (_showJSconsole) {
        NSString *console_log_js = WebViewJavascriptBridge_console_log_js();
        WKUserScript * console_log_userScript = [[WKUserScript alloc]initWithSource:console_log_js injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
        [_webView.configuration.userContentController addUserScript:console_log_userScript];
    }
}
- (void) addScriptMessageHandler {
    [_webView.configuration.userContentController addScriptMessageHandler:[[WebViewJavascriptLeakAvoider alloc]initWithDelegate:self] name:@"pipe"];
}

- (void)removeScriptMessageHandler {
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"pipe"];
}

- (NSString*) _evaluateJavascript:(NSString*)javascriptCommand {
    [_webView evaluateJavaScript:javascriptCommand completionHandler:nil];
    return NULL;
}

- (NSString *)_filterMessage:(NSString *) message {
    if (_enableLogging) {
         NSLog(@"All WVJB RCVD:%@",message);
    }
    if (message&& [message isKindOfClass:[NSString class]] && [message containsString:kBridgePrefix])
    {
        return message;
    }
    return nil;
}

- (void)dealloc {
    [self removeScriptMessageHandler];
}

NSString * WebViewJavascriptBridge_js() {
#define __WVJB_js_func__(x) #x
    
    // BEGIN preprocessorJSCode
    static NSString * preprocessorJSCode = @__WVJB_js_func__(
                                                             ;(function(window) {
               
        window.WebViewJavascriptBridge = {
        registerHandler: registerHandler,
        callHandler: callHandler,
        _handleMessageFromObjC: _handleMessageFromObjC
        };
        
        var sendMessageQueue = [];
        var messageHandlers = {};
        var responseCallbacks = {};
        var uniqueId = 1;
        
        function registerHandler(handlerName, handler) {
            messageHandlers[handlerName] = handler;
        }
        
        function callHandler(handlerName, data, responseCallback) {
            if (arguments.length === 2 && typeof data == 'function') {
                responseCallback = data;
                data = null;
            }
            _doSend({ handlerName:handlerName, data:data }, responseCallback);
        }
        function _doSend(message, responseCallback) {
            if (responseCallback) {
                var callbackId = 'cb_'+(uniqueId++)+'_'+new Date().getTime();
                responseCallbacks[callbackId] = responseCallback;
                message['callbackId'] = callbackId;
            }
            sendMessageQueue.push(message);
            window.webkit.messageHandlers.pipe.postMessage('__bridge__'+ JSON.stringify(sendMessageQueue));
            sendMessageQueue = [];
        }
        
        function _dispatchMessageFromObjC(messageJSON) {
            _doDispatchMessageFromObjC();
            
            function _doDispatchMessageFromObjC() {
                var message = JSON.parse(messageJSON);
                var messageHandler;
                var responseCallback;
                
                if (message.responseId) {
                    responseCallback = responseCallbacks[message.responseId];
                    if (!responseCallback) {
                       
                        return;
                    }
                    
                    responseCallback(message.responseData);
                    delete responseCallbacks[message.responseId];
                } else {
                    if (message.callbackId) {
                        var callbackResponseId = message.callbackId;
                        responseCallback = function(responseData) {
                            _doSend({ handlerName:message.handlerName, responseId:callbackResponseId, responseData:responseData });
                        };
                    }
                    var handler = messageHandlers[message.handlerName];
                    if (!handler) {
                        console.log("WebViewJavascriptBridge: WARNING: no handler for message from ObjC:", message);
                    } else {
                        handler(message.data, responseCallback);
                    }
                }
            }
        }
        function _handleMessageFromObjC(messageJSON) {
            _dispatchMessageFromObjC(messageJSON);
        }
    })(window);
                                                             ); // END preprocessorJSCode
    
#undef __WVJB_js_func__
    return preprocessorJSCode;
};

NSString * WebViewJavascriptBridge_console_log_js() {
#define __WVJB_js_func__(x) #x
    
    // BEGIN preprocessorJSCode
    static NSString * preprocessorJSCode = @__WVJB_js_func__(
                                                             ;(function(window) {
     let printObject = function (obj) {
          let output = "";
          if (obj === null) {
              output += "null";
          }
          else  if (typeof(obj) == "undefined") {
              output += "undefined";
          }
          else if (typeof obj ==='object'){
              output+="{";
              for(let key in obj){
                  let value = obj[key];
                  output+= "\""+key+"\""+":"+"\""+value+"\""+",";
              }
              output = output.substr(0, output.length - 1);
              output+="}";
          }
          else {
              output = "" + obj;
          }
          return output;
      };
        window.console.log = (function (oriLogFunc,printObject) {
          return function (str) {
              str = printObject(str);
              window.webkit.messageHandlers.pipe.postMessage(str);
              oriLogFunc.call(window.console, str);
          }
        })(window.console.log,printObject);

    })(window);
                                                             ); // END preprocessorJSCode
    
#undef __WVJB_js_func__
    return preprocessorJSCode;
};

@end
