//
//  UncaughtExceptionHandler.m
//  UncaughtExceptions
//
//  Created by Matt Gallagher on 2010/05/25.
//  Copyright 2010 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//http://www.360doc.com/content/15/0831/10/26281448_495965472.shtml
//https://www.jianshu.com/p/809ae3022cfd

#import "UncaughtExceptionHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

@implementation UncaughtExceptionHandler

+ (NSArray *)backtrace
{
    void* callstack[128];
    //  该函数用来获取当前线程调用堆栈的信息,获取的信息将会被存放在buffer中(callstack),它是一个指针数组。
    int frames = backtrace(callstack, 128);
    //  backtrace_symbols将从backtrace函数获取的信息转化为一个字符串数组.
    char **strs = backtrace_symbols(callstack, frames);

    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (
         i = UncaughtExceptionHandlerSkipAddressCount;
         i < UncaughtExceptionHandlerSkipAddressCount +
         UncaughtExceptionHandlerReportAddressCount;
         i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);

    return backtrace;
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
    if (anIndex == 0)
    {
        dismissed = YES;
    }
}

- (void)validateAndSaveCriticalApplicationData
{

}

- (void)handleException:(NSException *)exception
{
    [self validateAndSaveCriticalApplicationData];

//    UIAlertView *alert =
//    [[UIAlertView alloc]
//     initWithTitle:NSLocalizedString(@"Unhandled exception", nil)
//     message:[NSString stringWithFormat:NSLocalizedString(
//                                                          @"You can try to continue but the application may be unstable.\n\n"
//                                                          @"Debug details follow:\n%@\n%@", nil),
//              [exception reason],
//              [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]]
//     delegate:self
//     cancelButtonTitle:NSLocalizedString(@"Quit", nil)
//     otherButtonTitles:NSLocalizedString(@"Continue", nil), nil]
//    ;
//    [alert show];

    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);

    while (!dismissed)
    {
        for (NSString *mode in (__bridge NSArray *)allModes)
        {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }

    CFRelease(allModes);

    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);

    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName])
    {
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    }
    else
    {
        [exception raise];
    }
}

@end

void HandleException(NSException *exception)
{
    // 递增的一个全局计数器，很快很安全，防止并发数太大
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    // 获取 堆栈信息的数组
    NSArray *callStack = [UncaughtExceptionHandler backtrace];
    // 设置该字典
    NSMutableDictionary *userInfo =
    [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    // 给 堆栈信息 设置 地址 Key
    [userInfo
     setObject:callStack
     forKey:UncaughtExceptionHandlerAddressesKey];
    // 假如崩溃了执行 handleException: ，并且传出 NSException
    [[[UncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException
      exceptionWithName:[exception name]
      reason:[exception reason]
      userInfo:userInfo]
     waitUntilDone:YES];
}

void SignalHandler(int signal)
{
    // 递增的一个全局计数器，很快很安全，防止并发数太大
    //    此处注意OSAtomicIncrement32的使用，它此处是一个递增的一个全局计数器，效果又快又安全，是为了防止并发数太大出现错误的情况。
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    // 设置是哪一种 single 引起的问题
    NSMutableDictionary *userInfo =
    [NSMutableDictionary
     dictionaryWithObject:[NSNumber numberWithInt:signal]
     forKey:UncaughtExceptionHandlerSignalKey];
    // 获取 堆栈信息的数组
    NSArray *callStack = [UncaughtExceptionHandler backtrace];
    // 写入地址
    [userInfo
     setObject:callStack
     forKey:UncaughtExceptionHandlerAddressesKey];

    //  假如崩溃了执行 handleException: ，并且传出 NSException
    [[[UncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException
      exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
      reason:
      [NSString stringWithFormat:
       NSLocalizedString(@"Signal %d was raised.", nil),
       signal]
      userInfo:
      [NSDictionary
       dictionaryWithObject:[NSNumber numberWithInt:signal]
       forKey:UncaughtExceptionHandlerSignalKey]]
     waitUntilDone:YES];
}

void InstallUncaughtExceptionHandler(void)
{
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}

