Pod::Spec.new do |s|
  s.name         = 'WebViewJavascriptBridge'
  s.version      = '5.0.7'
  s.summary      = 'An iOS/OSX bridge for sending messages between Obj-C and JavaScript in UIWebViews/WebViews.'
  s.homepage     = 'https://github.com/marcuswestin/WebViewJavascriptBridge'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'marcuswestin' => 'marcus.westin@gmail.com' }
  s.requires_arc = true
  s.source       = { :git => 'https://github.com/marcuswestin/WebViewJavascriptBridge.git', :tag => 'v'+s.version.to_s }
  s.platforms = { :ios => "5.0", :osx => "" }
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.9'
  
  s.source_files = 'WebViewJavascriptBridge/*.{h,m}'
  s.private_header_files = 'WebViewJavascriptBridge/WebViewJavascriptBridge_JS.h'
  s.ios.framework    = 'UIKit'
  s.osx.framework    = 'WebKit'
end
