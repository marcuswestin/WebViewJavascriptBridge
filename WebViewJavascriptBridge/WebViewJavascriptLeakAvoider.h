//
//  LeakAvoider.h
//  ExampleApp-iOS
//
//  Created by 侯森魁 on 2020/4/20.
//  Copyright © 2020 Marcus Westin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface WebViewJavascriptLeakAvoider : NSObject<WKScriptMessageHandler>
@property(nonatomic,weak)id <WKScriptMessageHandler>  delegate;
- (instancetype)initWithDelegate:(id <WKScriptMessageHandler> )delegate;
@end

NS_ASSUME_NONNULL_END
