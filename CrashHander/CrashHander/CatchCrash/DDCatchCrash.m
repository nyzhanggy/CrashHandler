//
//  DDCatchCrash.m
//  DebugTool
//
//  Created by 张桂杨 on 2017/3/21.
//  Copyright © 2017年 DD. All rights reserved.
//

#import "DDCatchCrash.h"
#include <signal.h>
#include <execinfo.h>


@implementation DDCatchCrash

void uncaughtExceptionHandler(NSException *exception) {
    // 异常的堆栈信息
    NSArray *stackArray = [exception callStackSymbols];
    
    // 出现异常的原因
    NSString *reason = [exception reason];
    
    // 异常名称
    NSString *name = [exception name];
    
    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception reason：%@\nException name：%@\nException stack：%@",name, reason, stackArray];

    NSString *filePath = [DDCatchCrash filePath];
    [exceptionInfo writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


void sighandler(int signal) {
    const char* names[NSIG];
    names[SIGABRT] = "SIGABRT";
    names[SIGBUS] = "SIGBUS";
    names[SIGFPE] = "SIGFPE";
    names[SIGILL] = "SIGILL";
    names[SIGPIPE] = "SIGPIPE";
    names[SIGSEGV] = "SIGSEGV";
    
    
    void* callstack[128];
    const int numFrames = backtrace(callstack, 128);
    char **symbols = backtrace_symbols(callstack, numFrames);
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:numFrames];
    for (int i = 0; i < numFrames; ++i) {
        [arr addObject:[NSString stringWithUTF8String:symbols[i]]];
    }
    
    free(symbols);
    
    NSString *title = [NSString stringWithFormat:@"Crash: %@", [arr objectAtIndex:6]];  
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:arr, @"Callstack",
                              title, @"Title",
                              [NSNumber numberWithInt:signal], @"Signal",
                              [NSString stringWithUTF8String:names[signal]], @"Signal Name",
                              nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:userInfo options:NSJSONWritingPrettyPrinted error:nil];
    NSString *filePath = [DDCatchCrash filePath];
    [data writeToFile:filePath atomically:YES];
}

+ (void)startCatch {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    signal(SIGABRT, sighandler);
    signal(SIGBUS, sighandler);
    signal(SIGFPE, sighandler);
    signal(SIGILL, sighandler);
    signal(SIGPIPE, sighandler);
    signal(SIGSEGV, sighandler);
}


+ (BOOL)removWithFileName:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    return [fileManager removeItemAtPath:[[self crashDir] stringByAppendingString:fileName] error:nil];
}
+ (BOOL)removeAll {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:[self crashDir] error:nil];
}

+ (NSArray *)crashLogList {
    NSString *dirPath = [self crashDir];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    return files;
}

+ (NSString *)contentWithFileName:(NSString *)fileName {
    NSString *filePath = [[self crashDir] stringByAppendingString:fileName];
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return content;
}


+ (NSString *)filePath {
    NSString *dirPath = [self crashDir];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *datestr = [dateFormatter stringFromDate:[NSDate date]];
    
    return [dirPath stringByAppendingString:[NSString stringWithFormat:@"%@.log",datestr]];
}
+ (NSString *)crashDir {
    NSString *dirPath = [NSString stringWithFormat:@"%@/Library/Caches/crash/",NSHomeDirectory()];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:dirPath]) {
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dirPath;
}



@end
