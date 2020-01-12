

### 1.概念：

一般的线程，只执行一个任务，任务完成后退出。
runloop就是iOS里面的，让线程能随时处理事件，但不退出的机制。Event Loop
**实现模型的关键点**：如果管理事件/消息，如果在线程没有处理消息时休眠，以避免占用资源，在有消息来到时立刻被唤醒。
**Runloop**：实际上是一个对象，这个对象管理了需要处理的事件和消息，并提供了一个入口来执行runloop逻辑，线程结束后，就会一直处于这个函数“接受消息-等待-处理”的循环里，直至循环结束
**iOS**中，这样的对象有两个，**NSRunLoop,CFRunLoopRef**。
CFRunLoopRef:CoreFoundation框架内，提供纯C函数API，**线程安全**。
NSRunLoop:基于CFRunLoopRef的封装，提供面向对象的API，**不是线程安全**。
###2.runloop与线程的关系
开发中会遇到pthread_t对象，（基本上可以说明）它与NSThread一一对应。
**CFRunLoopRef是基于pthread来管理的**。
苹果不允许直接创建runloop，它只提供了两个自动获取函数 CFRunLoopGetMain(),CFRunLoopGetCurrent()。
**线程和runloop一一对应**，线程刚创建的时候并没有runloop,不主动获取就一直不会有。runloop的创建是发生在第一次获取的时候，销毁是在线程结束的时候（主线程除外），只能在一个线程里面获取其runloop，不能创建。
###3.runloop对外接口
CoreFoundation关于runloop有5个类，
CFRunLoopRef
CFRunLoopModeRef
CFRunLoopSourceRef
CFRunLoopTimerRef
CFRunLoopObserverRef，
其中CFRunLoopModeRef没有向外暴露，而是通过CFRunLoopRef进行了封装
关系：
![如图](http://cc.cocimg.com/api/uploads/20150528/1432798883604537.png)
一个**runloop**里面包含**若干**个**Mode**,每个Mode包含**若干**个Source/Time/Observer。每次调用runloop主函数时，只能指定其中一个Mode,这个Mode被称作CurrentMode。如果要切换Mood，只能退出loop再重新制定Mode进入，这样未来分隔开不同组的Source/Time/Observer,使其互不影响.

**Source(CFRunLoopSourceRef)**:事件产生的地方，source有两个版本，**Source0**:只包含一个函数指针，不主动触发事件。需要先把他标记为待处理（调用CFRunLoopSourceSignal(source)），然后手动欢迎runLoop(调用CFRunLoopWakeUp(runloop) ),让他处理事件。**Source1**:包含了一个 mach_port 和一个回调（函数指针），被用于通过内核和其他线程相互发送消息。这种 Source 能主动唤醒 RunLoop 的线程
**Timer(CFRunLoopTimerRef)**：是基于时间的触发器，当其加入到 RunLoop 时，RunLoop会注册对应的时间点，当时间点到时，RunLoop会被唤醒以执行那个回调。
**Observer(CFRunLoopObserverRef)**:观察者，每个 Observer 都包含了一个回调（函数指针），当 RunLoop 的状态发生变化时，观察者就能通过回调接受到这个变化.
 Source/Timer/Observer 被统称为 mode item,一个item可以被同时加入多个mode，但不能重复加入一个，如果一个mode一个item也没有，则runloop直接退出，不进入循环。

**mode**:"CommonModes"：一个 Mode 可以将自己标记为"Common"属性（通过将其 ModeName 添加到 RunLoop 的 "commonModes" 中）。每当 RunLoop 的内容发生变化时，RunLoop 都会自动将 _commonModeItems 里的 Source/Observer/Timer 同步到具有 "Common" 标记的所有Mode里。
例如：主线程的 RunLoop 里有两个预置的 Mode：kCFRunLoopDefaultMode 和 UITrackingRunLoopMode。这两个 Mode 都已经被标记为"Common"属性。DefaultMode 是 App 平时所处的状态，TrackingRunLoopMode 是追踪 ScrollView 滑动时的状态。当你创建一个 Timer 并加到 DefaultMode 时，Timer 会得到重复回调，但此时滑动一个TableView时，RunLoop 会将 mode 切换为 TrackingRunLoopMode，这时 Timer 就不会被回调，并且也不会影响到滑动操作。

###4.runloop内部逻辑
![内部逻辑](http://cc.cocimg.com/api/uploads/20150528/1432798974517485.png)
内部局势一个do-while循环，当调用CFRunLoopRun()是开始调用，

###5.底层实现
runloop核心是基于mach port的，
***OSX/iOS系统架构：1.应用层：用户能接触到的图形应用。2.应用框架层：开发人员接触到的cocoa等框架。3.核心框架层：核心框架，OpenGL等。4.Darwin,操作系统核心***
RunLoop 的核心就是一个 mach_msg() ,RunLoop 调用这个函数去接收消息，如果没有别人发送 port 消息过来，内核会将线程置于等待状态

###6.runloop实现的功能：
系统默认注册了5个mode。
1. kCFRunLoopDefaultMode: App的默认 Mode，通常主线程是在这个 Mode 下运行的。

2. UITrackingRunLoopMode: 界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响。
3....4...5...

应用：
#####(1).AutoreleasePool,
app启动后，苹果在主线程创建时注册了两个observer,
第一个监听entry，即将进入loop，创建自动释放池，优先级最好，以保证创建释放池事件发生在其他回掉之前。
第二个监听 beforeWaiting和exit，beforeWaiting（准备进入休眠）,释放旧池并创建新池，exit，释放自动释放池。它的优先级最低，保证其释放池子发生在其他回掉之后。
在主线程执行的代码桐城市在回掉事件内的，会被runloop创建好的自动释放池环绕，内部不会出现内存泄漏，所以不用单独创建。
####(2).事件响应：
苹果注册了一个Source1,来接受系统事件（触摸，锁屏，摇晃等）。由IOKit。framework生成事件并由springboard(跳板)接受,它只接收几种事件（按键，触摸，加速，传感器等），然后调用mach pord(底层的呃一种消息发送机制)传给app进程，然后Source1就触发回掉，在应用内部分发。
触摸手势，包括Gesture/屏幕旋转,发送给window等，按钮点击、touchesBegin/Move/End/Cancel事件都是在这里回掉完成的
####(3).手势识别，
根据上面说的，当识别了一个手势，会先调用cancel将当前回掉打断，然后系统对手势标记为待处理。
苹果注册了一个Observer监听BeforeWaiting，有一个回掉函数，其内部会获取所有刚被标记为待处理的事件，执行手势回掉
####(4).界面更新
操作ui时（改变frame,更新层级等）,就会把view/layer标记为待处理，苹果注册了一个Observer监听BeforeWaiting和Exit，执行回掉，函数里会便利所有待处理的页面，更新页面
####(5).定时器
NSTimer 其实就是 CFRunLoopTimerRef,一个 NSTimer 注册到 RunLoop 后，RunLoop 会为其重复的时间点注册好事件.RunLoop为了节省资源，并不会在非常准确的时间点回调这个Timer。Timer 有个属性叫做 Tolerance (宽容度)，标示了当时间点到后，容许有多少最大误差。如果时间错过了，那个时间点会被跳过。
####(6). PerformSelecter
当调用 NSObject 的 performSelecter:afterDelay: 后，实际上其内部会创建一个 Timer 并添加到当前线程的 RunLoop 中。所以如果当前线程没有 RunLoop，则这个方法会失效。
当调用 performSelector:onThread: 时，实际上其会创建一个 Timer 加到对应的线程去
####(7).关于GCD
两者相互调用，runloop用dispatch_source_t实现timer,dispatch_async()使用了runloop
调用dispatch_async(dispatch_get_main_queue(), block)时【仅限于 dispatch 到主线程】，libDispatch 会向主线程的 RunLoop 发送消息，RunLoop会被唤醒，并从消息中取得这个 block，并在回调 
####(8).网络请求
使用NSURLConnection时，会传入一个delegate,调用了[connection start],delegate会一直收到回掉，
其实，start函数内部会获取CurrentRunLoop,在DefaultMode添加了4个Source0, 传输开始Connection创建了两个新线程，其中NSURLConnectionLoader线程内部会使用runloop来接受底层的scoket事件，并通过Source0传到上层delegate里面。



###应用分析
####AFNetworking分析：
AFURLConnectionOperation是基于NSURLConnection，作用为在后台接受Delegate回掉，为此AFN单独创建了一个线程，在这个线程里面启动了runloop,为了保证runloop存在，创建了一个NSMachPort添加进入了，当需要这个后天线程执行任务时，AFN通过调用 [NSObject performSelector:onThread:..] 将这个任务扔到了后台线程的 RunLoop 中。
####AsyncDisplayKit，为保持界面流畅性的框架。
原理：UI线程造成卡顿的原因：繁重任务：
排版：计算视图大小，计算文本高度，重新计算子视图排版
绘制：文本绘制（CoreText），图片绘制，元素绘制
ui对象的操作：view/layer等的创建，属性设置，销毁
前脸哥哥可以丢到后台线程执行，最后一个只能在主线程执行，并且依赖于前两步的操作。
ASDK就是把能放后台的放后台，不能的尽量推迟。
ASDK 创建了一个名为 ASDisplayNode 的对象，并在内部封装了 UIView/CALayer，它具有和 UIView/CALayer 相似的属性。所有这些属性都可以在后台线程更改，开发者可以只通过 Node 来操作其内部的 UIView/CALayer，这样就可以将排版和绘制放入了后台线程。但是无论怎么操作，这些属性总需要在某个时刻同步到主线程的 UIView/CALayer 去。
ASDK 仿照 QuartzCore/UIKit 框架的模式，实现了一套类似的界面更新的机制：**即在主线程的 RunLoop 中添加一个 Observer，监听了 kCFRunLoopBeforeWaiting 和 kCFRunLoopExit 事件，在收到回调时，遍历所有之前放入队列的待处理的任务，然后一一执行**。



[原文链接](http://www.cocoachina.com/ios/20150601/11970.html)