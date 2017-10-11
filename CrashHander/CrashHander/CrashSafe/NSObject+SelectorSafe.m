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
        [self swizzleInstanceMethod:@selector(methodSignatureForSelector:) withNew:@selector(dd_methodSignatureForSelector:)];
        [self swizzleInstanceMethod:@selector(forwardInvocation:) withNew:@selector(dd_forwardInvocation:)];
        
    });
}
#endif

- (NSMethodSignature *)dd_methodSignatureForSelector:(SEL)sel{
    
    NSMethodSignature *sig;
    sig = [self dd_methodSignatureForSelector:sel];
    if (sig) {
        return sig;
    }
    
    sig = [[_UnregSelObjectProxy sharedInstance] dd_methodSignatureForSelector:sel];
    if (sig){
        return sig;
    }
    
    return nil;
}

- (void)dd_forwardInvocation:(NSInvocation *)anInvocation{
    [anInvocation invokeWithTarget:[_UnregSelObjectProxy sharedInstance] ];
}

@end
