//
//  LeakAvoider.m
//  ExampleApp-iOS
//
//  Created by 侯森魁 on 2020/4/20.
//  Copyright © 2020 Marcus Westin. All rights reserved.
//

#import "WebViewJavascriptLeakAvoider.h"

@implementation WebViewJavascriptLeakAvoider
- (instancetype)initWithDelegate:(id <WKScriptMessageHandler> )delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
}
@end
