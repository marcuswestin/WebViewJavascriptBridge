package com.example.WebViewJavascriptBridgeExample;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.webkit.WebView;
import com.fangjian.WebViewJavascriptBridge;

import java.io.InputStream;

public class MyActivity extends Activity {
    private WebView webView;

    /**
     * Called when the activity is first created.
     */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        webView=(WebView) this.findViewById(R.id.webView);
        WebViewJavascriptBridge bridge=
                new WebViewJavascriptBridge(this.getApplicationContext(),webView,new UserHandler()) ;
        loadSample();
    }

    private void loadSample(){
        InputStream is=getResources().openRawResource(R.raw.sample);
        String sample=WebViewJavascriptBridge.convertStreamToString(is);
        webView.loadData(sample,"text/html","UTF-8");
    }

    class UserHandler implements WebViewJavascriptBridge.WVJBHandler{
        @Override
        public void handle(String data, WebViewJavascriptBridge.WVJBResponseCallback jsCallback) {
              Log.d("test", data);
              jsCallback.callback("java said received:"+data);
        }
    }
}
