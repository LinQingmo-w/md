[链接](https://www.jianshu.com/p/c99f4974ddb5)

## block原理是什么，本质是什么

block本质上也是一个oc对象，内部也有一个isa指针。block是封装了函数以及函数调用环境的oc对象.

block定义中调用了 `__main_block_impl_0`函数，并且将 `__main_block_impl_0`函数的地址赋值给了block。

 `__main_block_imp_0` 是一个结构体

![img](https://upload-images.jianshu.io/upload_images/1434508-beb290d0acd377b1.png?imageMogr2/auto-orient/strip|imageView2/2/w/770)

结构体内有一个同名构造函数`__main_block_imp_0`，构造函数中对一些变量进行了赋值最终会返回一个结构体。

`__main_block_impl_0`构造函数中传入了四个参数。`(void *)__main_block_func_0`、`&__main_block_desc_0_DATA`、`age`、`flags`。其中flage有默认值，也就说flage参数在调用的时候可以省略不传。age(_age)则表示传入的_age参数会自动赋值给age成员，相当于age = _age。**age代表局部变量**。

`__main_block_func_0`函数中其实存储着我们block中写下的代码。而`__main_block_impl_0`函数中传入的是`(void *)__main_block_func_0`，也就说将我们写在block块中的代码封装成`__main_block_func_0`函数，并将`__main_block_func_0`函数的地址传入了`__main_block_impl_0`的构造函数中保存在结构体内。

`__main_block_desc_0`中存储着两个参数，`reserved`和`Block_size`，并且`reserved`赋值为0而`Block_size`则存储着`__main_block_impl_0`的占用空间大小。最终将`__main_block_desc_0`结构体的地址传入`__main_block_func_0`中赋值给`Desc`。



age也就是我们定义的局部变量。因为在block块中使用到age局部变量，所以在block声明的时候这里才会将age作为参数传入，也就说block会捕获age，如果没有在block中使用age，这里将只会传入 `(void *)__main_block_func_0`， `&__main_block_desc_0_DATA` 两个参数。**捕获使用的变量，作为参数传入。**

因为block在定义的之后已经将age的值传入存储在`__main_block_imp_0`结构体中并在调用的时候将age从block中取出来使用，因此在block定义之后对局部变量进行改变是无法被block捕获的。



`__main_block_impl_0`结构体包含 impl,Desc,变量，`__main_block_impl_0`.

impl 是一个结构体，包含 isa, flags, reserved,funcptr.



我们可以发现__block_impl结构体内部就有一个isa指针。因此可以证明block本质上就是一个oc对象。而在构造函数中将函数中传入的值分别存储在__main_block_impl_0结构体实例中，最终将结构体的地址赋值给block。

接着通过上面对`__main_block_impl_0`结构体构造函数三个参数的分析我们可以得出结论：
**1. `__block_impl`结构体中isa指针存储着`&_NSConcreteStackBlock`地址，可以暂时理解为其类对象地址，block就是`_NSConcreteStackBlock`类型的。**
**2. block代码块中的代码被封装成`__main_block_func_0`函数，FuncPtr则存储着`__main_block_func_0`函数的地址。**
**3. Desc指向`__main_block_desc_0`结构体对象，其中存储`__main_block_impl_0`结构体所占用的内存。**

FunPtr中存储着通过代码块封装的函数地址，那么调用此函数，也就是会执行代码块中的代码。



![img](https://upload-images.jianshu.io/upload_images/1434508-6c88e7465aac23a0.png?imageMogr2/auto-orient/strip|imageView2/2/w/869)







![img](https://upload-images.jianshu.io/upload_images/1434508-1ecebe9ad79c8c11.png?imageMogr2/auto-orient/strip|imageView2/2/w/989)







一个bolck是即使是一个oc对象，在存储的时候是以结构体方式存储。结构体包含impl, desc,和捕获的变量。其中impl包含isa指针，flag，reserved = 0,和FuncPtr。FuncPtr是执行的函数块。 desc主要是描述block信息的，包含大小，data,最终将最终将`__main_block_desc_0`结构体的地址传入`__main_block_func_0`中赋值给Desc。



局部变量是通过捕获的，如果方法中没有用到变量，就不会捕获，也就没有这个属性。



auto自动变量，离开作用域就销毁，局部变量前面自动添加auto关键字。自动变量会捕获到block内部，也就是说block内部会专门新增加一个参数来存储变量的值。
auto只存在于局部变量中，访问方式为**值传递**，通过上述对age参数的解释我们也可以确定确实是值传递。



static 修饰的变量为指针传递，同样会被block捕获。

而auto是传值，static是传地址。原因是自动变量可能会被销毁，在执行时，自动变量可能已经被销毁了，在去访问地址就不可以。而静态变量不会被销毁，所以可以传地址。



而全局变量并没有在block结构体中添加变量，因此block不需要捕获全局变量，因为全局变量在哪里都可以访问，所以不需要捕获。



![img](https://upload-images.jianshu.io/upload_images/1434508-fc81811bcf0e5398.png?imageMogr2/auto-orient/strip|imageView2/2/w/644)



**局部变量都会被block捕获，自动变量是值捕获，静态变量为地址捕获。全局变量则不会被block捕获**

**self为局部变量，会被捕获的。**不论对象方法还是类方法都会默认将self作为参数传递给方法内部，既然是作为参数传入，那么self肯定是局部变量。上面讲到局部变量肯定会被block捕获。

即使block中使用的是实例对象的属性，block中捕获的仍然是实例对象，并通过实例对象通过不同的方式去获取使用到的属性。





block的类型：block的isa指针是指向_NSConcreteStackBlock类对象地址，最终基础自NSBlock，继承与NSObject.



![img](https://upload-images.jianshu.io/upload_images/1434508-180cead6473c3ca8.png?imageMogr2/auto-orient/strip|imageView2/2/w/744)

block呦三种类型  `__NSGlobalBlock__` - 数据段，以初始化的全局变量，静态变量，直到程序结束才会被回收,`__NSStackBlock__` 栈内存，自动分配，作用域执行完毕就会被系统回收,`__NSMallocBlock__`,堆内存，alloc出来的对象，动态分配内存，需要自己进行内存管理.



栈中的内存由系统自动分配和释放，作用域执行完毕之后就会被立即释放，而在相同的作用域中定义block并且调用block似乎也多此一举。



![img](https://upload-images.jianshu.io/upload_images/1434508-131f0569fa47538a.png?imageMogr2/auto-orient/strip|imageView2/2/w/691)





![img](https://upload-images.jianshu.io/upload_images/1434508-74811a740c972d8e.png?imageMogr2/auto-orient/strip|imageView2/2/w/689)





**ARC处理：自动将栈上的block进行一次copy操作，将block复制到堆上。 会这样做的情况：1. block作为返回值返回时。2. block赋值给_strong指针时。3. block作为Cocoa API中方法名含有usingBlock的方法参数时。遍历数组的block方法，将block作为参数的时候。4. block作为GCD API的方法参数时。GDC的一次性函数或延迟执行的函数，执行完block操作之后系统才会对block进行release操作**



person作为一个oc对象被创建，变量作为auto对象被传入，传入的blick的变量通用为person，block就会有一个强引用来引用person，所以block不被销毁，person也不会被销毁。所以block被copy过后，persn不会被销毁

也就是说栈空间上的block不会对对象强引用，堆空间的block有能力持有外部调用的对象，即对对象进行强引用或去除强引用的操作。

所以`__weak`，添加了它，person在作用域执行完毕之后就会被销毁。`__weak`修饰的变量，在生成的`__main_block_impl_0`中也是使用`__weak`修饰。

栈上的对象，不会发生强引用，所以不用`__weak`修饰。如果被拷贝到堆上，会调用`_Block_object_assign`,根据auto对象的类型进行修饰。如果block从堆中移除，`dispose`函数会调用`_Block_object_dispose`函数，自动释放引用的auto变量。





## __block的作用是什么？有什么使用注意点？

修改block内部的值。用于解决block内部不能修改auto变量值的问题。它不能修饰static和全局变量。

修改内部值的方法有：1.使用static修饰，放到静态区。 2. __block。3.全局变量。

编译器会将__block修饰的值包装成一个对象。调用的时候从对象中去值。





## block的属性修饰词为什么是copy？使用block有哪些使用注意？





## block在修改NSMutableArray，需不需要添加__block？

不需要。block中仅仅是array的内存地址，往内存中添加内容并没有修改array的内存地址，因此不需要__block也能编译。

当仅仅是使用局部变量的内存地址，而不是修改的时候，尽量不要添加__block。一旦添加，系统就会自动创建相应的结构体，栈永不叙用的空间。



当`block`被`copy`到堆上时，`block`内部引用的`__block`变量也会被复制到堆上，并且持有变量，如果`block`复制到堆上的同时，`__block`变量已经存在堆上了，则不会复制。

没有使用`__block`修饰的变量（object 和 weadObj）则根据他们本身被block捕获的指针类型对他们进行强引用或弱引用，而一旦使用`__block`修饰的变量，`__main_block_impl_0`结构体内一律使用强指针引用生成的结构体。



`__forwarding`指针指向的是结构体自己。当使用变量的时候，通过结构体找到`__forwarding`指针，在通过`__forwarding`指针找到相应的变量。为了方便内存管理。通过上面对`__block`变量的内存管理分析我们知道，`block`被复制到堆上时，会将`block`中引用的变量也复制到堆中。

![img](https://upload-images.jianshu.io/upload_images/1434508-f1196104d11e8d0b?imageMogr2/auto-orient/strip|imageView2/2/w/894)





copy函数会将person地址传入`_Block_object_assign`函数，`_Block_object_assign`中对Person对象进行强引用或者弱引用。

如何`block`内部中对`__block`修饰变量生成的结构体都是强引用，结构体内部对外部变量的引用取决于传入block内部的变量是强引用还是弱引用。