package com.fangjian;
import android.content.Context;
import android.util.Log;
import android.webkit.*;
import android.widget.Toast;
import com.example.WebViewJavascriptBridgeExample.R;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;

/**
 * Created with IntelliJ IDEA.
 * User: jack_fang
 * Date: 13-8-15
 * Time: 下午6:08
 */
public class WebViewJavascriptBridge {

    WebView mWebView;
    Context mContext;
    WVJBHandler _messageHandler;
    Map<String,WVJBHandler> _messageHandlers;
    Map<String,WVJBResponseCallback> _responseCallbacks;
    long _uniqueId;
    public WebViewJavascriptBridge(Context context,WebView webview,WVJBHandler handler) {
        this.mContext=context;
        this.mWebView=webview;
        this._messageHandler=handler;
        _messageHandlers=new HashMap<String,WVJBHandler>();
        _responseCallbacks=new HashMap<String, WVJBResponseCallback>();
        _uniqueId=0;
        WebSettings webSettings = mWebView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        mWebView.addJavascriptInterface(this, "WebViewJavascriptBridge");
        mWebView.setWebViewClient(new MyWebViewClient());
        mWebView.setWebChromeClient(new MyWebChromeClient());     //optional, for show console and alert
    }


    private void loadWebViewJavascriptBridgeJs(WebView webView) {
        InputStream is=mContext.getResources().openRawResource(R.raw.webviewjavascriptbridge);
        String script=convertStreamToString(is);
        webView.loadUrl("javascript:"+script);

    }

    public static String convertStreamToString(java.io.InputStream is) {
        String s="";
        try{
            Scanner scanner = new Scanner(is, "UTF-8").useDelimiter("\\A");
            if (scanner.hasNext()) s= scanner.next();
            is.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return s;
    }

    private class MyWebViewClient extends WebViewClient {
        @Override
        public void onPageFinished(WebView webView, String url) {
            Log.d("test","onPageFinished");
            loadWebViewJavascriptBridgeJs(webView);
        }
    }

    private class MyWebChromeClient extends WebChromeClient {
        @Override
        public boolean onConsoleMessage(ConsoleMessage cm) {
            Log.d("test", cm.message() + " -- From line "
                    + cm.lineNumber() + " of "
                    + cm.sourceId() );
            return true;
        }

        @Override
        public boolean onJsAlert(WebView view, String url, String message, JsResult result) {
            Toast.makeText(mContext, message, Toast.LENGTH_SHORT).show();
            return true;
        }
    }

    public interface WVJBHandler{
        public void handle(String data,WVJBResponseCallback jsCallback);
    }

    public interface WVJBResponseCallback{
        public void callback(String data);
    }

    public void registerHandler(String handlerName,WVJBHandler handler) {
        _messageHandlers.put(handlerName,handler);
    }

    private class CallbackJs implements WVJBResponseCallback{
        private final String callbackIJs;

        public  CallbackJs(String callbackIJs){
            this.callbackIJs=callbackIJs;
        }
        @Override
        public void callback(String data) {
               _callbackJs(callbackIJs,data);
        }
    }


    private void _callbackJs(String callbackIJs,String data) {
    }

    @JavascriptInterface
    public void _handleMessageFromJs(String data,String responseId,
                                     String responseData,String callbackId,String handlerName){
        if (null!=responseId) {
            WVJBResponseCallback responseCallback = _responseCallbacks.get(responseId);
            responseCallback.callback(responseData);
            _responseCallbacks.remove(responseId);
        } else {
            WVJBResponseCallback responseCallback = null;
            if (null!=callbackId) {
                responseCallback=new CallbackJs(callbackId);
            }
            WVJBHandler handler;
            if (null!=handlerName) {
                handler = _messageHandlers.get(handlerName);
                if (null==handler) {
                    Log.e("test","WVJB Warning: No handler for "+handlerName);
                    return ;
                }
            } else {
                handler = _messageHandler;
            }
            try {
                handler.handle(data, responseCallback);
            }catch (Exception exception) {
                Log.e("test","WebViewJavascriptBridge: WARNING: java handler threw. "+exception.getMessage());
            }
        }
    }

    public void send(String data) {
        send(data,null);
    }

    public void send(String data ,WVJBResponseCallback responseCallback) {
        _sendData(data,responseCallback,null);
    }

    private void _sendData(String data,WVJBResponseCallback responseCallback,String  handlerName){
        Map <String, String> message=new HashMap<String,String>();
        message.put("data",data);
        if (null!=responseCallback) {
            String callbackId = "java_cb_"+ (++_uniqueId);
            _responseCallbacks.put(callbackId,responseCallback);
            message.put("callbackId",callbackId);
        }
        if (null!=handlerName) {
            message.put("handlerName", handlerName);
        }
        _dispatchMessage(message);
    }

    private void _dispatchMessage(Map <String, String> message){
        String messageJSON = new JSONObject(message).toString();
        Log.d("test","sending:"+messageJSON);
        String javascriptCommand =
                String.format("javascript:WebViewJavascriptBridge._handleMessageFromOJava('%s');",messageJSON);
        mWebView.loadUrl(javascriptCommand);
    }

    public  void callHandler(String handlerName) {
        callHandler(handlerName, null, null);
    }

    public void callHandler(String handlerName,String data) {
        callHandler(handlerName, data,null);
    }

    public void callHandler(String handlerName,String data,WVJBResponseCallback responseCallback){
        _sendData(data, responseCallback,handlerName);
    }

}
