package com.airymiao.android.exampleapp_android;


import android.content.DialogInterface;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.webkit.WebView;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import com.airymiao.android.webviewjavascriptbridge.WebViewJavascriptBridgeClient;

public class MainActivity extends AppCompatActivity {

    private static final String AppLogTag = "WebViewJavascriptBridge";

    WebView bridgeWebView;
    WebViewJavascriptBridgeClient bridgeWebViewClient;
    String urlString;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                MainActivity.this.executeJavascriptCommand();
            }
        });

        this.urlString = "http://192.168.11.77:8080/";
        this.renderWebView();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    /**
     * Web View Bridge Center
     */
    private void renderWebView() {
        bridgeWebView = (WebView) findViewById(R.id.webview);

        this.registerJavascriptBridge(bridgeWebView);

        Map<String, String> noCacheHeaders = new HashMap<>(2);
        noCacheHeaders.put("Pragma", "no-cache");
        noCacheHeaders.put("Cache-Control", "no-cache");

        bridgeWebView.loadUrl(this.urlString, noCacheHeaders);
    }

    private void registerJavascriptBridge(WebView bridgeWebView) {
        bridgeWebViewClient = new WebViewJavascriptBridgeClient(bridgeWebView);

        bridgeWebViewClient.enableLogging();

        this.bindJavascriptBridge();
    }

    private void executeJavascriptCommand() {
        JSONObject jsonData = new JSONObject();
        try {
            JSONObject messageData = new JSONObject();
            messageData.put("content", "From Android");

            jsonData.put("code", "2000");
            jsonData.put("type", "alert");
            jsonData.put("message", messageData);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        bridgeWebViewClient.callHandler("demo-web", jsonData, new WebViewJavascriptBridgeClient.WVJBResponseCallback() {
            @Override
            public void callback(Object data) {
                Log.v(AppLogTag, "Response data from web:" + data.toString());
            }
        });
    }

    private void bindJavascriptBridge() {
        bridgeWebViewClient.registerHandler("demo-app", new WebViewJavascriptBridgeClient.WVJBHandler() {
            @Override
            public void request(Object data, WebViewJavascriptBridgeClient.WVJBResponseCallback callback) {
                Log.v(AppLogTag, "Received data from web:" + data.toString());

                callback.callback(data);

                MainActivity.this.handleJavascriptBridgeCommand(data);
            }
        });
    }

    private void handleJavascriptBridgeCommand(Object data) {
        JSONObject jsonObject = (JSONObject) data;

        try {
            String type = jsonObject.getString("type");
            if (type.equals("alert")) {
                JSONObject messageJSONObject = jsonObject.getJSONObject("message");
                this.executeAlert(messageJSONObject.getString("content"));
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void executeAlert(String message) {

        if (message == null || message.isEmpty()) {
            return;
        }

        AlertDialog alertDialog = new AlertDialog.Builder(MainActivity.this).create();
        alertDialog.setTitle(message);
        alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, "OK",
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                });
        alertDialog.show();
    }
}
