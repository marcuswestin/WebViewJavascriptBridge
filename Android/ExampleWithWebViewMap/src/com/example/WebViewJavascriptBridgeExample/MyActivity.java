package com.example.WebViewJavascriptBridgeExample;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.Toast;

import com.fangjian.WebViewJavascriptBridge;

import java.io.InputStream;

public class MyActivity extends Activity {
    private WebView webView;
    private Button button1;
    private Button button2;
    private Button button3;
    private WebViewJavascriptBridge bridge;

    /**
     * Called when the activity is first created.
     */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        webView=(WebView) this.findViewById(R.id.webView);
        bridge=new WebViewJavascriptBridge(this,webView,new UserServerHandler()) ;
        button1=(Button)this.findViewById(R.id.button1);
        button2=(Button)this.findViewById(R.id.button2);
        button3=(Button)this.findViewById(R.id.button3);
        registerButtons();
        loadUserClient();
    }

    private void registerButtons() {
		button1.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v) {
				if(null!=bridge){
					bridge.callHandler("gotoMarker","1");
				}			
			}
		});	
		button2.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v) {
				if(null!=bridge){
					bridge.callHandler("gotoMarker","2");
				}			
			}
		});	
		button3.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v) {
				if(null!=bridge){
					bridge.callHandler("gotoMarker","3");
				}			
			}
		});	
	}

    
	private void loadUserClient(){
        InputStream is=getResources().openRawResource(R.raw.user_client);
        String user_client_html=WebViewJavascriptBridge.convertStreamToString(is);
       // webView.loadData(user_client_html,"text/html","UTF-8");
        webView.loadUrl("file:///android_asset/map/map.html");
    }

    class UserServerHandler implements WebViewJavascriptBridge.WVJBHandler{
        @Override
        public void handle(String id, WebViewJavascriptBridge.WVJBResponseCallback jsCallback) {
        	String msg="user click marker: "+ id;
            Log.d("test",msg);
            Toast.makeText(MyActivity.this, msg, Toast.LENGTH_SHORT).show();
        }
    }


}
