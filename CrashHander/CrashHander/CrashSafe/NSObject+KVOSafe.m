//
//  NSObject+KVOSafe.m


#import "NSObject+KVOSafe.h"
#import <objc/runtime.h>
#import "NSObject+DDSwizzleMethod.h"
#import "CrashSafeConfig.h"

@implementation NSObject (KVOSafe)

static const void *keypathMapKey=&keypathMapKey;

- (NSMapTable <id, NSHashTable<NSString *> *> *)keypathMap {
    NSMapTable *keypathMap = objc_getAssociatedObject(self, &keypathMapKey);
    if (keypathMap) {
        return keypathMap;
    }
    keypathMap = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality valueOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
    objc_setAssociatedObject(self, &keypathMapKey, keypathMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return keypathMap;
}

- (void)setKeypathMap:(id)map{
    if (map) {
        objc_setAssociatedObject(self, keypathMapKey, map, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

#if KOV_safe_on
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(addObserver:forKeyPath:options:context:) withNew:@selector(dd_addObserver:forKeyPath:options:context:)];
        [self swizzleInstanceMethod:@selector(removeObserver:forKeyPath:) withNew:@selector(dd_removeObserver:forKeyPath:)];
        
        [self swizzleInstanceMethod:NSSelectorFromString(@"dealloc") withNew:@selector(dd_dealloc)];
    });
}
#endif
- (void)dd_dealloc {
    if ([self isKindOfClass:[NSObject class]]) {
        if ([self keypathMap]) {
            NSLog(@"%@",[self keypathMap].keyEnumerator);
        }
        NSLog(@"xxxx");
    }
   
    [self dd_dealloc];
}
-(void)dd_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    
    if (!observer || !keyPath) {
        return;
    }
    NSHashTable *table = [[self keypathMap] objectForKey:observer];
    
    if (!table) {
        table =  [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
        [table addObject:keyPath];
        [[self keypathMap] setObject:table forKey:observer];
        [self dd_addObserver:observer forKeyPath:keyPath options:options context:context];
        return;
    }
    
    if ([table containsObject:keyPath]) {
        NSLog(@"%s ******* donot add the same observer and keypath %@ ",__FUNCTION__, self);
        return;
    }
    [table addObject:keyPath];
}

-(void)dd_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    
    if(!observer || !keyPath){
        return;
    }
    
    NSHashTable *table = [[self keypathMap] objectForKey:observer];
    if (!table) {
        return;
    }
    
    if (![table containsObject:keyPath]) {
        NSLog(@"%s ******* donot remove the keypath not existed %@ ",__FUNCTION__, self);
        return;
    }
    [table removeObject:keyPath];

}


@end
