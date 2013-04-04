Pod::Spec.new do |s|
  s.name         = "WebViewJavascriptBridge"
  s.version      = "2.1.1"
  s.summary      = "A standalone iOS class for sending messages to and from javascript in a UIWebView."
  s.homepage     = "http://github.com/marcuswestin/WebViewJavascriptBridge"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "marcuswestin" => "marcus.westin@gmail.com" }
  s.source       = { :git => "https://github.com/marcuswestin/WebViewJavascriptBridge.git", :tag => "2.1.1" }
  s.platform     = :ios, "4.2"
  s.source_files = "WebViewJavascriptBridge/WebViewJavascriptBridge.{h,m}"
  s.resource     = "WebViewJavascriptBridge/WebViewJavascriptBridge.js.txt"
  s.framework    = "UIKit"
  s.dependency     "JSONKit"
end
