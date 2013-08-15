package com.fangjian;
import android.webkit.JavascriptInterface;

/**
 * Created with IntelliJ IDEA.
 * User: jack_fang
 * Date: 13-8-15
 * Time: 下午6:08
 */
public class WebViewJavascriptBridge {

    public WebViewJavascriptBridge() {
    }

    @JavascriptInterface
    public void callJava(int callbackId,String message){
         System.out.println(message+"\n callbackId:"+callbackId);
    }
}
