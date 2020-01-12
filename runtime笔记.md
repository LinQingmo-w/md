#1.Class 和isa 

objc_object 结构体包含一个 isa 指针，类型为 isa_t 联合体。根据 isa 就可以顺藤摸瓜找到对象所属的类。isa 这里还涉及到 tagged pointer 等概念
isa 指针不总是指向实例对象所属的类，不能依靠它来确定类型，而是应该用 class 方法来确定实例对象的类。因为KVO的实现机理就是将被观察对象的 isa 指针指向一个中间类而不是真实的类，这是一种叫做 isa-swizzling 的技术
![isa和superClass 示意图](http://7ni3rk.com1.z0.glb.clouddn.com/Runtime/class-diagram.jpg)

[class链接](http://www.zhimengzhe.com/IOSkaifa/253119.html)

#2.寻找 IMP 的过程(查找过程):

方法调用流程
在 Objective-C 中，所有的 [receiver message] 都会转换为 objc_msgSend(receiver, @selector(message));


1.在当前 class 的方法缓存里寻找（cache methodLists）
找到了跳到对应的方法实现，没找到继续往下执行
2.从当前 class 的 方法列表里查找（methodLists），找到了添加到缓存列表里，然后跳转到对应的方法实现；没找到继续往下执行
3.从 superClass 的缓存列表和方法列表里查找，直到找到基类为止
4.以上步骤还找不到 IMP，则用_objc_msgForward函数指针代替 IMP 。最后，执行这个 IMP 。
[链接](https://www.jianshu.com/p/4db013fa8c02)

#3.下面是消息转发的流程（转发过程）：

第一个**接手的具体方法**是+(BOOL)resolveInstanceMethod:(SEL)sel 和+(BOOL)resolveClassMethod:(SEL)sel，当方法是实例方法时调用前者，当方法为类方法时，调用后者。这个方法设计的目的是为了给类利用 class_addMethod 添加方法的机会。（这不是重点）
第二个阶段是**备援接收者**阶段，对象的具体方法是-(id)forwardingTargetForSelector:(SEL)aSelector ，此时，运行时询问能否把消息转给其他接收者处理，也就是此时系统给了个将这个 SEL 转给其他对象的机会。(这也不是重点)
第三个阶段是**完整消息转发**阶段，对应方法-(void)forwardInvocation:(NSInvocation *)anInvocation，这是消息转发流程的最后一个环节。（这个是重点，hook方案的核心集中在这里）



[链接](https://www.jianshu.com/p/4db013fa8c02)

![图例](https://upload-images.jianshu.io/upload_images/1951455-fc72441e0940743b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/700)

#4.方法替换  Method Swizzling

```
#import <objc/runtime.h> 
 
@implementation UIViewController (Tracking) 
 
+ (void)load { 
    static dispatch_once_t onceToken; 
    dispatch_once(&onceToken, ^{ 
        Class aClass = [self class]; 
 			// When swizzling a class method, use the following:
        // Class aClass = object_getClass((id)self);
        
        SEL originalSelector = @selector(viewWillAppear:); 
        SEL swizzledSelector = @selector(xxx_viewWillAppear:); 
 
        Method originalMethod = class_getInstanceMethod(aClass, originalSelector); 
        Method swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector); 
 
        BOOL didAddMethod = 
            class_addMethod(aClass, 
                originalSelector, 
                method_getImplementation(swizzledMethod), 
                method_getTypeEncoding(swizzledMethod)); 
 
        if (didAddMethod) { 
            class_replaceMethod(aClass, 
                swizzledSelector, 
                method_getImplementation(originalMethod), 
                method_getTypeEncoding(originalMethod)); 
        } else { 
            method_exchangeImplementations(originalMethod, swizzledMethod); 
        } 
    }); 
} 
 
#pragma mark - Method Swizzling 
 
- (void)xxx_viewWillAppear:(BOOL)animated { 
    [self xxx_viewWillAppear:animated]; 
    NSLog(@"viewWillAppear: %@", self); 
} 
 
@end

```

上面的代码通过添加一个Tracking类别到UIViewController类中，将UIViewController类的viewWillAppear:方法和Tracking类别中xxx_viewWillAppear:方法的实现相互调换。
Swizzling 应该在+load方法中实现，因为+load是在一个类最开始加载时调用。
dispatch_once是GCD中的一个方法，它保证了代码块只执行一次，并让其为一个原子操作，线程安全是很重要的。

最后xxx_viewWillAppear:方法的定义看似是递归调用引发死循环，其实不会的。**因为[self xxx_viewWillAppear:animated]消息会动态找到xxx_viewWillAppear:方法的实现，而它的实现已经被我们与viewWillAppear:方法实现进行了互换，所以这段代码不仅不会死循环**，如果你把[self xxx_viewWillAppear:animated]换成[self viewWillAppear:animated]反而会引发死循环。

#5.hook 埋点
钩子(Hook)，应用程序可以在上面设置子程以监视指定窗口的某种消息，而且所监视的窗口可以是其他进程所创建的。当消息到达后，在目标窗口处理函数之前处理它。钩子机制允许应用程序截获处理window消息或特定事件

埋点也叫日志上报，其实就是根据需求上报一系列关于用户行为的数据.
[埋点](http://ios.jobbole.com/85746/)