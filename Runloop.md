[链接](https://www.jianshu.com/p/74db5638f34f)

## 简介

运行循环，在程序运行过程中循环做一些事情，如果没有Runloop程序执行完毕就会立即退出，如果有Runloop程序会一直运行，并且时时刻刻在等待用户的输入操作。RunLoop可以在需要的时候自己跑起来运行，在没有操作的时候就停下来休息。充分节省CPU资源，提高程序性能。



## 基本作用

1. **保持程序持续运行**，程序一启动就会开一个主线程，主线程一开起来就会跑一个主线程对应的RunLoop,RunLoop保证主线程不会被销毁，也就保证了程序的持续运行

2. **处理App中的各种事件**（比如：触摸事件，定时器事件，Selector事件等）

3. **节省CPU资源，提高程序性能**，程序运行起来时，当什么操作都没有做的时候，RunLoop就告诉CUP，现在没有事情做，我要去休息，这时CUP就会将其资源释放出来去做其他的事情，当有事情做的时候RunLoop就会立马起来去做事情



## 在哪里开启

UIApplicationMain函数内启动了Runloop，程序不会马上退出，而是保持运行状态。在程序的入口main函数中开启。是在main中的死循环。



## Runloop对象

Fundation框架 （基于CFRunLoopRef的封装）
NSRunLoop对象

CoreFoundation
CFRunLoopRef对象



获得Runloop

```objective-c
Foundation
[NSRunLoop currentRunLoop]; // 获得当前线程的RunLoop对象
[NSRunLoop mainRunLoop]; // 获得主线程的RunLoop对象

Core Foundation
CFRunLoopGetCurrent(); // 获得当前线程的RunLoop对象
CFRunLoopGetMain(); // 获得主线程的RunLoop对象
```



## Runloop和线程之间的关系

1. 每条线程都有一个唯一与之对应的Runloop对象
2. Runloop保存在一个全局的Dictionary里面，线程作为key,Runloop作为value
3. 主线程的Runloop已经创建好了，子线程的Runloop需要主动创建。
4. Runloop在第一次获取时创建，在线程结束时销毁。



## Runloop结构体

```objectivec
CFRunLoopModeRef _currentMode;
CFMutableSetRef _modes;
```

CFRunLoopModeRef指向一个__CFRunLoopMode结构体

```objectivec
CFMutableSetRef _sources0;
CFMutableSetRef _sources1;
CFMutableArrayRef _observers;
CFMutableArrayRef _timers;
```

CFRunLoopModeRef代表RunLoop的运行模式，一个RunLoop包含若干个Mode，每个Mode又包含若干个Source0/Source1/Timer/Observer，而RunLoop启动时只能选择其中一个Mode作为currentMode。



**1. Source1 : 基于Port的线程间通信**

**2. Source0 : 触摸事件，PerformSelectors**

**3. Timers : 定时器，NSTimer**

**4. Observer : 监听器，用于监听RunLoop的状态**



## 相关类及作用

1. CFRunLoopModeRef 

	CFRunLoopModeRef代表RunLoop的运行模式
	一个 RunLoop 包含若干个 Mode，每个Mode又包含若干个Source、Timer、Observer
	每次RunLoop启动时，只能指定其中一个 Mode，这个Mode被称作 CurrentMode
	如果需要切换Mode，只能退出RunLoop，再重新指定一个Mode进入，这样做主要是为了分隔开不同组的Source、Timer、Observer，让其互不影响。如果Mode里没有任何Source0/Source1/Timer/Observer，RunLoop会立马退出

	一种Mode中可以有多个Source(事件源，输入源，基于端口事件源例键盘触摸等) Observer(观察者，观察当前RunLoop运行状态) 和Timer(定时器事件源)。但是必须至少有一个Source或者Timer，因为如果Mode为空，RunLoop运行到空模式不会进行空转，就会立刻退出。

	系统默认主次5个mode

	```objectivec
	1. kCFRunLoopDefaultMode：App的默认Mode，通常主线程是在这个Mode下运行
	2. UITrackingRunLoopMode：界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响
	3. UIInitializationRunLoopMode: 在刚启动 App 时第进入的第一个 Mode，启动完成后就不再使用，会切换到kCFRunLoopDefaultMode
	4. GSEventReceiveRunLoopMode: 接受系统事件的内部 Mode，通常用不到
	5. kCFRunLoopCommonModes: 这是一个占位用的Mode，作为标记kCFRunLoopDefaultMode和UITrackingRunLoopMode用，并不是一种真正的Mode 
	```

	```objectivec
	-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
	{
	    // [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(show) userInfo:nil repeats:YES];
	    NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(show) userInfo:nil repeats:YES];
	    // 加入到RunLoop中才可以运行
	    // 1. 把定时器添加到RunLoop中，并且选择默认运行模式NSDefaultRunLoopMode = kCFRunLoopDefaultMode
	    // [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	    // 当textFiled滑动的时候，timer失效，停止滑动时，timer恢复
	    // 原因：当textFiled滑动的时候，RunLoop的Mode会自动切换成UITrackingRunLoopMode模式，因此timer失效，当停止滑动，RunLoop又会切换回NSDefaultRunLoopMode模式，因此timer又会重新启动了
	    
	    // 2. 当我们将timer添加到UITrackingRunLoopMode模式中，此时只有我们在滑动textField时timer才会运行
	    // [[NSRunLoop mainRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
	    
	    // 3. 那个如何让timer在两个模式下都可以运行呢？
	    // 3.1 在两个模式下都添加timer 是可以的，但是timer添加了两次，并不是同一个timer
	    // 3.2 使用站位的运行模式 NSRunLoopCommonModes标记，凡是被打上NSRunLoopCommonModes标记的都可以运行，下面两种模式被打上标签
	    //0 : <CFString 0x10b7fe210 [0x10a8c7a40]>{contents = "UITrackingRunLoopMode"}
	    //2 : <CFString 0x10a8e85e0 [0x10a8c7a40]>{contents = "kCFRunLoopDefaultMode"}
	    // 因此也就是说如果我们使用NSRunLoopCommonModes，timer可以在UITrackingRunLoopMode，kCFRunLoopDefaultMode两种模式下运行
	    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
	    NSLog(@"%@",[NSRunLoop mainRunLoop]);
	}
	-(void)show
	{
	    NSLog(@"-------");
	}
	```

2. CFRunLoopSourceRef  事件源
	source 分为两种，
	Source0：非基于Port的 用于用户主动触发的事件（点击button 或点击屏幕）
	Source1：基于Port的 通过内核和其他线程相互发送消息（与内核相关）

3. CFRunLoopObserverRef 

	**观察者，能够监听RunLoop的状态改变**



## 处理流程



![img](https://upload-images.jianshu.io/upload_images/1434508-d448ec1fc5171e09?imageMogr2/auto-orient/strip|imageView2/2/w/747)



## Runloop退出

1. 主线程销毁RunLoop退出
2. Mode中有一些Timer 、Source、 Observer，这些保证Mode不为空时保证RunLoop没有空转并且是在运行的，当Mode中为空的时候，RunLoop会立刻退出
3. 我们在启动RunLoop的时候可以设置什么时候停止

```objective-c
[NSRunLoop currentRunLoop]runUntilDate:<#(nonnull NSDate *)#>
[NSRunLoop currentRunLoop]runMode:<#(nonnull NSString *)#> beforeDate:<#(nonnull NSDate *)#>
```



## Runloop的使用

1. 常住线程
2. 自动释放池