//
//  NSDictionary+NilSafe.m

#import "NSDictionary+NilSafe.h"
#import <objc/runtime.h>
#import "NSObject+DDSwizzleMethod.h"
#import "CrashSafeConfig.h"
@implementation NSDictionary (NilSafe)

#if dictionary_nil_safe_on

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(initWithObjects:forKeys:count:) withNew:@selector(dd_initWithObjects:forKeys:count:)];
        [self swizzleClassMethodWithOrig:@selector(dictionaryWithObjects:forKeys:count:) withNew:@selector(dd_dictionaryWithObjects:forKeys:count:)];
    });
}
#endif

+ (instancetype)dd_dictionaryWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt {
    id safeObjects[cnt];
    id safeKeys[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key) {
            continue;
        }
        if (!obj) {
            obj = [NSNull null];
        }
        safeKeys[j] = key;
        safeObjects[j] = obj;
        j++;
    }
    return [self dd_dictionaryWithObjects:safeObjects forKeys:safeKeys count:j];
}

- (instancetype)dd_initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt {
    id safeObjects[cnt];
    id safeKeys[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key) {
            continue;
        }
        if (!obj) {
            obj = [NSNull null];
        }
        safeKeys[j] = key;
        safeObjects[j] = obj;
        j++;
    }
    return [self dd_initWithObjects:safeObjects forKeys:safeKeys count:j];
}

@end



