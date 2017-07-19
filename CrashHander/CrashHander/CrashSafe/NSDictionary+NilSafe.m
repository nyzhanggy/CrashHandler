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

@implementation NSMutableDictionary (NilSafe)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = NSClassFromString(@"__NSDictionaryM");
        [class swizzleInstanceMethod:@selector(setObject:forKey:) withNew:@selector(dd_setObject:forKey:)];
        [class swizzleInstanceMethod:@selector(setObject:forKeyedSubscript:) withNew:@selector(dd_setObject:forKeyedSubscript:)];
    });
}

- (void)dd_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (!aKey) {
        return;
    }
    if (!anObject) {
        anObject = [NSNull null];
    }
    [self dd_setObject:anObject forKey:aKey];
}

- (void)dd_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    if (!key) {
        return;
    }
    if (!obj) {
        obj = [NSNull null];
    }
    [self dd_setObject:obj forKeyedSubscript:key];
}

@end

@implementation NSNull (NilSafe)


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(methodSignatureForSelector:) withNew:@selector(dd_methodSignatureForSelector:)];
        [self swizzleInstanceMethod:@selector(forwardInvocation:) withNew:@selector(dd_forwardInvocation:)];
    });
}

- (NSMethodSignature *)dd_methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sig = [self dd_methodSignatureForSelector:aSelector];
    if (sig) {
        return sig;
    }
    return [NSMethodSignature signatureWithObjCTypes:@encode(void)];
}

- (void)dd_forwardInvocation:(NSInvocation *)anInvocation {
    NSUInteger returnLength = [[anInvocation methodSignature] methodReturnLength];
    if (!returnLength) {
        // nothing to do
        return;
    }

    // set return value to all zero bits
    char buffer[returnLength];
    memset(buffer, 0, returnLength);

    [anInvocation setReturnValue:buffer];
}

@end
