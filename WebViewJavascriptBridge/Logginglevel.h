//
//  Logginglevel.h
//  ExampleApp-iOS
//
//  Created by 侯森魁 on 2020/3/25.
//  Copyright © 2020 Marcus Westin. All rights reserved.
//

typedef enum {
    //Only printf JSON In Xcode Command line
    LogginglevelJSONOnly = 1 << 0,
    //All String  printf In Xcode Command line
    LogginglevelAll = 1 << 1,
}Logginglevel;

