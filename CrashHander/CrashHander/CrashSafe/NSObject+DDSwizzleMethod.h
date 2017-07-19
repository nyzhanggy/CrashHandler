//
//  NSObject+DDSwizzleMethod.h

#import <Foundation/Foundation.h>

@interface NSObject (DDSwizzleMethod)
+ (void)swizzleInstanceMethod:(SEL)orig withNew:(SEL)new;
+ (void)swizzleClassMethodWithOrig:(SEL)orig withNew:(SEL)new;
@end
