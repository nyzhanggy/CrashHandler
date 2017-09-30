//
//  CrashSafe.h
//  DebugTool
//
//  Created by 张桂杨 on 2017/3/22.
//  Copyright © 2017年 DD. All rights reserved.
//

#import "DDCatchCrash.h"

#define IS_CUSTOM_CLASS [NSBundle bundleForClass:[self class]] == [NSBundle mainBundle]


#ifndef CrashSafe_h
#define CrashSafe_h

#define KOV_safe_on             1
#define selector_safe_on        1

#define array_nil_safe_on       1
#define dictionary_nil_safe_on  1


#endif
