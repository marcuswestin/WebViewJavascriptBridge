//
//  WKWebViewJavascriptBridge_JS.h
//  ExampleApp-iOS
//
//  Created by 侯森魁 on 2020/3/25.
//  Copyright © 2020 Marcus Westin. All rights reserved.
//


NSString * _WebViewJavascriptBridge_js() {
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
      console.log = (function (oriLogFunc,printObject) {
          return function (str) {
              str = printObject(str);
              window.webkit.messageHandlers.log.postMessage(str);
              oriLogFunc.call(console, str);
          }
      })(console.log,printObject);
        
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
            console.log('__bridge__'+ JSON.stringify(sendMessageQueue));
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
