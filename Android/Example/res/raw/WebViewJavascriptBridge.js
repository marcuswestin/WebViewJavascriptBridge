WebViewJavascriptBridge._handleMessageFromJava=function(messageJSON){
     console.log(messageJSON);
     var json=JSON.parse(messageJSON);
     for(var k in json){
        console.log(json[k]);
     }
}