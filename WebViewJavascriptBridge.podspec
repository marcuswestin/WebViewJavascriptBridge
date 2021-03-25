Pod::Spec.new do |s|
  s.name         = 'WebViewJavascriptBridge'
  s.version      = '6.0.4'
  s.summary      = 'An iOS & OSX bridge for sending messages between Obj-C/Swift and JavaScript in WKWebViews & WebViews.'
  s.homepage     = 'https://github.com/marcuswestin/WebViewJavascriptBridge'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'marcuswestin' => 'marcus.westin@gmail.com' }
  s.source       = { :git => 'https://github.com/marcuswestin/WebViewJavascriptBridge.git', :tag => 'v'+s.version.to_s }
  s.platforms    = { :ios => "8.0", :osx => "" }
  s.requires_arc = true
  
  s.source_files         = 'WebViewJavascriptBridge/*.{h,m}'
  s.private_header_files = 'WebViewJavascriptBridge/WebViewJavascriptBridge_JS.h'
  
  s.frameworks       = 'WebKit'
  s.ios.frameworks   = 'UIKit', 'WebKit'
end
