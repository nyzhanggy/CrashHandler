//
//  NSObject+SelectorSafe.m


#import "NSObject+SelectorSafe.h"
#import <objc/runtime.h>
#import "NSObject+DDSwizzleMethod.h"
#import "CrashSafeConfig.h"
@interface _UnregSelObjectProxy : NSObject
+ (instancetype) sharedInstance;
@end

@implementation _UnregSelObjectProxy

+ (instancetype) sharedInstance{
    
    static _UnregSelObjectProxy *instance=nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        instance = [[_UnregSelObjectProxy alloc] init];
    });
    return instance;
}

+ (BOOL) resolveInstanceMethod:(SEL)selector {
    
    class_addMethod([self class], selector,(IMP)emptyMethodIMP,"v@:");
    return YES;
}

void* emptyMethodIMP(){
    return nil;
}

@end

@implementation NSObject (SelectorSafe)

#if selector_safe_on
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(forwardingTargetForSelector:) withNew:@selector(dd_forwardingTargetForSelector:)];
    });
}
#endif

- (id)dd_forwardingTargetForSelector:(SEL)aSelector {
    return [_UnregSelObjectProxy sharedInstance];
}
@end
