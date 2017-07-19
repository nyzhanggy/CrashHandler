//
//  NSObject+DDSwizzleMethod.m


#import "NSObject+DDSwizzleMethod.h"
#import <objc/runtime.h>

@implementation NSObject (DDSwizzleMethod)

+ (void)swizzleClassMethodWithOrig:(SEL)orig withNew:(SEL)new {
    Method origMethod = class_getClassMethod(self, orig);
    Method newMethod = class_getClassMethod(self, new);
    
    Class c = object_getClass((id)self);
    BOOL didAddMethod = class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if(didAddMethod) {
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }


}
+ (void)swizzleInstanceMethod:(SEL)orig withNew:(SEL)new {
    Method origMethod = class_getInstanceMethod(self, orig);
    Method newMethod = class_getInstanceMethod(self, new);
    BOOL didAddMethod = class_addMethod(self, orig,method_getImplementation(newMethod),method_getTypeEncoding(newMethod));
    if (didAddMethod) {
        class_replaceMethod(self, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}


@end
