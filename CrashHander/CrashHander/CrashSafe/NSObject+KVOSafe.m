//
//  NSObject+KVOSafe.m


#import "NSObject+KVOSafe.h"
#import <objc/runtime.h>
#import "NSObject+DDSwizzleMethod.h"
#import "CrashSafeConfig.h"

@implementation NSObject (KVOSafe)

static const void *keypathMapKey=&keypathMapKey;
static const void *autoManagerKVOKey=&autoManagerKVOKey;

- (NSMapTable <id, NSHashTable<NSString *> *> *)keypathMap {
    NSMapTable *keypathMap = objc_getAssociatedObject(self, &keypathMapKey);
    if (keypathMap) {
        return keypathMap;
    }
    keypathMap = [NSMapTable strongToStrongObjectsMapTable];
    objc_setAssociatedObject(self, &keypathMapKey, keypathMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return keypathMap;
}

- (void)setKeypathMap:(id)map{
    if (map) {
        objc_setAssociatedObject(self, keypathMapKey, map, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

-(BOOL)autoManagerKVO{
    return  [objc_getAssociatedObject(self,_cmd) boolValue];
}

- (void)setAutoManagerKVO:(BOOL)autoManagerKVO {
    objc_setAssociatedObject(self, @selector(autoManagerKVO), @(autoManagerKVO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

    if (self.autoManagerKVO) {
        NSString *ivar = [NSString stringWithFormat:@"%p",self];
        self.autoManagerKVO = NO;
        for (NSObject *observer in [self keypathMap].keyEnumerator) {
            NSHashTable *table = [[self keypathMap] objectForKey:observer];
            for (NSString *keypath in table) {
                if ([observer isKindOfClass:[NSString class]] && [ivar isEqualToString:(NSString *)observer]) {
                    [self removeObserver:self forKeyPath:keypath];
                } else {
                    [self removeObserver:observer forKeyPath:keypath];
                }
            }
        }
    }
    [self dd_dealloc];
}

-(void)dd_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    if (self.autoManagerKVO) {
        if (!observer || !keyPath) {
            return;
        }

        NSObject *observerkey = observer;
        //如果观察者是self，直接放入keypathMap 中会引起循环引用
        if (observer == self) {
            observerkey = [NSString stringWithFormat:@"%p",self];
        }
    
        NSHashTable *table = [[self keypathMap] objectForKey:observerkey];
        
        if (!table) {
            table =  [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
            [[self keypathMap] setObject:table forKey:observerkey];
        }
        
        if ([table containsObject:keyPath]) {
            NSArray *callStackSymbols = [NSThread callStackSymbols];
            NSString *crashLog = [NSString stringWithFormat:@"reason: <%@ %p> had have observer <%@ %p> for keypath  '%@',do no add again.\n%@ ",[self class],self,[observer class],observer,keyPath,callStackSymbols];
            [DDCatchCrash addCrashLog:crashLog];
            return;
        }
        [table addObject:keyPath];
    }
    
    [self dd_addObserver:observer forKeyPath:keyPath options:options context:context];
}

-(void)dd_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    if (self.autoManagerKVO) {
        if(!observer || !keyPath){
            return;
        }
        NSArray *callStackSymbols = [NSThread callStackSymbols];
        
        NSString *crashLog = [NSString stringWithFormat:@"reason: Cannot remove an observer <%@ %p> for the key path '%@' from <%@ %@> because it is not registered as an observer. \n%@",[observer class],observer,keyPath,[observer class],observer,callStackSymbols];
        
        NSHashTable *table = [[self keypathMap] objectForKey:observer];
        if (!table) {
            [DDCatchCrash addCrashLog:crashLog];
            return;
        }
        
        if (![table containsObject:keyPath]) {
            [DDCatchCrash addCrashLog:crashLog];
            return;
        }
        [table removeObject:keyPath];
    }
    
    [self dd_removeObserver:observer forKeyPath:keyPath];
    
   
}


@end
