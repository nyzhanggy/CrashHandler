//
//  NSArray+NilSafe.m
//  DebugTool
//
//  Created by 张桂杨 on 2017/3/22.
//  Copyright © 2017年 DD. All rights reserved.
//

#import "NSArray+NilSafe.h"
#import <objc/runtime.h>
#import "NSObject+DDSwizzleMethod.h"
#import "CrashSafeConfig.h"

@implementation NSArray (NilSafe)

#if dictionary_nil_safe_on

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleClassMethodWithOrig:@selector(arrayWithObjects:count:) withNew:@selector(dd_arrayWithObjects:count:)];
        [self swizzleInstanceMethod:@selector(initWithObjects:count:) withNew:@selector(dd_initWithObjects:count:)];
    });
}
#endif

+ (instancetype)dd_arrayWithObjects:(const id  _Nonnull __unsafe_unretained *)objects count:(NSUInteger)cnt {
    id safeObjects[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        id obj = objects[i];
        if (!obj) {
            obj = [NSNull null];
        }
        safeObjects[j] = obj;
        j++;
    }
    return [self dd_arrayWithObjects:safeObjects count:cnt];
}
- (instancetype)dd_initWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt {
    id safeObjects[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        id obj = objects[i];
        if (!obj) {
            obj = [NSNull null];
        }
        safeObjects[j] = obj;
        j++;
    }
    return [self dd_initWithObjects:safeObjects count:cnt];
}


@end


