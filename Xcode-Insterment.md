1. 调试：p/po

	p:打印值

	po: 打印description方法

2. Buildtime issue , Runtime issue

	Buildtime issue:编译时的错误,警告，错误，静态分析（未初始化变量，未使用数据，API使用错误（如未调用super））

	Runtime issue:运行时错误。线程问题、UI布局和渲染问题、内存问题。

3. app启动优化

	1. 查看分析日志，添加时间变量，查看启动时间。DYLD_PRINT_STATISTICS
	2. 出现问题：动态加载库，重定位/绑定，对象初始化
	3. 解决：减少动态累（苹果建议不多于6个），减少累数量（合并或删除，会加快动态链接，重定位和绑定会快）,用initialize替换load方法或load方法延迟调用（减少初始化时间）

4. 检查循环引用

	1. xcode的memory debug cgaph,在调试栏
	2. runtime issue
	3. leak - cellTree.建议在display中候选separate by thread 和 hide system libraries，会隐藏系统和应用自身的调用路径。

5. EXD_BAD_ACCESS

	1. 全局断点：效果一般

	2. 重写object的respondsToSelecotr: 一般，并要在每个类单独排查，不易操作

	3. zombie 和address sanitizer.在edit scheme




 [原文链接](https://www.jianshu.com/p/92cd90e65d4c)

- 介绍
性能分析、动态跟踪和分析
收集关于一个或多个系统进程的性能和行为的数据，并能及时随着时间跟踪而产生的数据，并检查所收集的数据
广泛收集不同类型的数据
追踪程序运行的过程
- 能做的事
版本一：
1.动态追踪和分析代码性能分析和测试工具
2.支持多线程调试
3.可录制和回放，图形用户界面的操作过程
4.可将录制的图形界面操作和Instruments保存为模本，供以后方便使用
版本二：
1.追踪代码中的问题，甚至是难以复制的
2.分析程序性能
3.实现程序自动化测试
4.部分实现程序压力测试
5.执行系统级别的通用问题追踪调试
6.使你对程序内不允许过程更了解
- 常用工具介绍
![界面](http://upload-images.jianshu.io/upload_images/2773034-a2bf9cabf91cb72a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
1.Blank(空模版): 可从Library库中添加其他模版
2.Activity Monitor（活动监视器）:显示器处理的CPU,内存,磁盘和网络使用情况统计。
3.Allocations(内存分配)：跟踪过程的匿名虚拟内存和堆的对象提供类名和可选 retain/release历史记录。 监测内存使用/分配情况【常用】
4.Cocoa Layout(约束状态):观察约束变化，找出布局代码的问题所在。
5.Core Animation(动画)：通过时间进程测量页面图形性能
6.Core Data(数据):监测读取、缓存未命中、保存等操作，能直观显示是否保存次数远超实际需要。
7.Counters(计数):使用时间或事件抽样方式手机性能监视器计数(PMC)事件。
8.Engergy Log(能源日志)：基础开关状态和主要设备组建的能源使用诊断。
9.File Activity(文档分析)：监视文件和目录的活动，包括文档打开/关闭，文件权限修改，目录创建，文件移动
10.Leaks(内存泄漏)：检测一般内存使用情况，检查内存泄漏，并通过类名检测所有活动分配和内存泄漏的内存地址历史
11.Mstal System Trace("金属"系统跟踪)：通过提供类子应用程序，驱动和GPU层的跟踪信息，元系统检测iOS/tvOS/macOS的金属程序性能
12.NetWork(网络)：分析程序使用链接工具使用TCP/IP,UDP/IP链接的方式
13.SceneKit(三维开发)：分析应用SceneKit的使用。确定每个框架的工作类型，例如动画，物理，场景筛选，渲染；
14.System Trace(系统跟踪)：操作系统工作内容的全面了解，理解CPU进程调度，虚拟内存使用和内存故障如何影响应用程序的性能
15.System Usage(系统使用 IO)：记录了文档，套接字和人间共享内存相关的IO系统活动，每次调用都提供单个进程的输入，输出，持续时间，回溯，调用树等
16.Time Proflier(时间分析)：运行在系统CPU上的进程的低开销的机遇时间的系统采用
17.Zombies(僵尸对象)：测量一般的内存使用，专门检查过度释放的僵尸对象，还提供了类的对象分配的统计信息以及所有活动非配的内存地址历史记录



[调试](https://www.cnblogs.com/Leo_wl/p/4423922.html)