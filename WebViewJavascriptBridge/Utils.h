//
//  Utils.h
//  ExampleApp-iOS
//
//  Created by 侯森魁 on 2020/3/25.
//  Copyright © 2020 Marcus Westin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Logginglevel.h"
NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject
+ (NSString *)serializeMessage:(id)message pretty:(BOOL)pretty;
+ (NSArray*)deserializeMessageJSON:(NSString *)messageJSON;
+ (void)log:(NSString *)action json:(id)json loggingLevel:(Logginglevel)loggingLevel;
+ (NSString *)replacingJSONString:(NSString *)messageJSON;
@end

NS_ASSUME_NONNULL_END
