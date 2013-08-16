package com.fangjian;
import android.content.Context;
import android.util.Log;
import android.webkit.*;
import android.widget.Toast;
import com.example.WebViewJavascriptBridgeExample.R;
import java.io.IOException;
import java.io.InputStream;
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
    public WebViewJavascriptBridge(Context context,WebView webview) {
        this.mContext=context;
        this.mWebView=webview;
        WebSettings webSettings = mWebView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        mWebView.addJavascriptInterface(this, "WebViewJavascriptBridge");
        mWebView.setWebViewClient(new MyWebViewClient());
        mWebView.setWebChromeClient(new MyWebChromeClient());     //optional, for show console and alert
    }

    @JavascriptInterface
    public void callJava(Integer callbackId,String message){
         Log.i("test", message + " callbackId:" + callbackId);  //id为0，等同null
        Log.i("test", "message is null?"+(message== null) ) ;
        Log.i("test", "id is null?"+(callbackId == null) ) ;
    }


    /** Show a toast from the web page */
    @JavascriptInterface
    public void showToast(String toast) {
        Toast.makeText(mContext, toast, Toast.LENGTH_SHORT).show();
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
            showToast(message);
            return true;
        }
    }
}
