package com.example.WebViewJavascriptBridgeExample;

import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebView;
import com.fangjian.WebViewJavascriptBridge;

public class MyActivity extends Activity {
    /**
     * Called when the activity is first created.
     */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        WebView webView=(WebView) this.findViewById(R.id.webView);
        webView.addJavascriptInterface(new WebViewJavascriptBridge(),"WebViewJavascriptBridge");
    }
}
