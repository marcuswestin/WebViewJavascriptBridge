#Meow Web View Bridge

Android webView bridge for sending message based on [marcuswestin/WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge)

### Examples

Install [http-server](https://www.npmjs.com/package/http-server),then start front-end server `cd Front-end && http-server -p 8080`

Open either the iOS or Android project,change `urlString` to match local IP address with port like `http://*.*.*.*:8080`.Then run to see the demo


### Usage

#### Front-end

1. Add meow-bridge.js to your project

2. Register bridge handler for app

  ```
  window.webViewBridge.registerHandler("demo-web",function(data,responseCallback){
    responseCallback(data);
    console.log(JSON.stringify(data));
  });
  ```

3. Call bridge method to invoke app matched method

  ```
  window.webViewBridge.callHandler("demo-app", {
    "code": 200,
    "type": "alert",
    "message": {"content": "From front-end!"}
  }, function (responseData) {
    console.log(JSON.stringify(responseData));
  });
  ```

#### Android

1. Add `web-view-javascript-bridge.jar` into your project,then import webView client.The source code is in module `webviewjavascriptbridge`.Use gradle task `createJar` to generate jar

  ```
  import com.airymiao.android.webviewjavascriptbridge.WebViewJavascriptBridgeClient;
  ```

2. Initialize bridge

  ```
  WebView bridgeWebView = (WebView) findViewById(R.id.webview);
  WebViewJavascriptBridgeClient bridgeWebViewClient = new WebViewJavascriptBridgeClient(bridgeWebView);
  ```

3. Register bridge handler for front-end

  ```
  bridgeWebViewClient.registerHandler("demo-app", new WebViewJavascriptBridgeClient.WVJBHandler() {
     @Override
     public void request(Object data, WebViewJavascriptBridgeClient.WVJBResponseCallback callback) {
         Log.v("WebViewJavascriptBridgeClient", "Received data from web:" + data.toString());

         callback.callback(data);
     }
  });
  ```

4. Call bridge method to invoke front-end matched method

  ```
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

  bridgeWebViewClient.callHandler("demo-web", jsonData, new WebViewJavascriptBridgeClient.WVJBResponseCallback()   {
       @Override
       public void callback(Object data) {
           Log.v("WebViewJavascriptBridgeClient", "Response data from web:" + data.toString());
       }
  });
  ```
