//
//  DDCatchCrash.h
//  DebugTool
//
//  Created by 张桂杨 on 2017/3/21.
//  Copyright © 2017年 DD. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DDCatchCrash : NSObject
+ (void)startCatch;
+ (NSArray *)crashLogList;
+ (NSString *)contentWithFileName:(NSString *)fileName;
+ (BOOL)removWithFileName:(NSString *)fileName;
+ (BOOL)removeAll;
@end
