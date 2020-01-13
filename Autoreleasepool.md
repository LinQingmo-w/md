## 局部释放池

ARC下:

```objective-c
@autoreleasepool {
  Student *s = [[Student alloc] init];
}
```

相当于MRC下

```objective-c
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init;
Student *s = [[Student alloc] init];
[pool drain];
```

其中对象s会被加入到自动释放池，当ARC下代码执行到右大括号时（相当于MRC执行代码`[pool drain];`）会对池中所有对象依次执行一次`release`操作



## Runloop和自动释放池

> NSRunLoop :
>
> App启动后，苹果在主线程 RunLoop 里注册了两个 Observer，其回调都是 _wrapRunLoopWithAutoreleasePoolHandler()。
>
> 第一个 Observer 监视的事件是 Entry(即将进入Loop)，其回调内会调用 _objc_autoreleasePoolPush() 创建自动释放池。其 order 是-2147483647(-2^32^-1)，优先级最高，保证创建释放池发生在其他所有回调之前。
>
> 第二个 Observer 监视了两个事件： BeforeWaiting(准备进入休眠) 时调用_objc_autoreleasePoolPop() 和 _objc_autoreleasePoolPush() 释放旧的池并创建新池；Exit(即将退出Loop) 时调用 _objc_autoreleasePoolPop() 来释放自动释放池。这个 Observer 的 order 是 2147483647(2^32^-1)，优先级最低，保证其释放池子发生在其他所有回调之后。



**Autoreleasepool对象从哪里来:** 对于每一个Runloop运行循环，系统会隐式创建一个`Autoreleasepool`对象，`+ (instancetype)student`中执行`autorelease`的操作就会将`student`对象添加到这个系统隐式创建的
`Autoreleasepool`对象中

**Autoreleasepool对象又会在何时调用[pool drain]方法:**当Runloop执行完一系列动作没有更多事情要它做时，它会进入休眠状态，避免一直占用大量系统资源，或者Runloop要退出时会触发执行`_objc_autoreleasePoolPop()`方法相当于让`Autoreleasepool`对象执行一次`drain`方法，`Autoreleasepool`对象会对自动释放池中所有的对象依次执行依次`release`操作



**子线程的autoRelease:**子线程默认不会开启 Runloop.在子线程你创建了 Pool 的话，产生的 Autorelease 对象就会交给 pool 去管理。如果你没有创建 Pool ，但是产生了 Autorelease 对象，就会调用 autoreleaseNoPage 方法。在这个方法中，会自动帮你创建一个 hotpage（hotPage 可以理解为当前正在使用的 AutoreleasePoolPage，如果你还是不理解，可以先看看 Autoreleasepool 的源代码，再来看这个问题 ），并调用 `page->add(obj)`将对象添加到 AutoreleasePoolPage 的栈中，也就是说你不进行手动的内存管理，也不会内存泄漏啦！

