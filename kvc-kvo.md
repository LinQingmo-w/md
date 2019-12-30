### KVC

Key Value Coding

通过字符串的名字（key）来访问类属性的机制。而不是通过调用Setter、Getter方法访问。

通过isa指针定位

用来动态取值和设值

用kvc来访问和修改私有变量

model字典的转换

修改控件内部属性

####  设值

1.首先搜索是否有`setKey:`的方法（key是成员变量名，首字母大写）,没有则会搜索是否有`setIsKey:`的方法。

2.如果没有找到`setKey:`的方法,此时看`+ (BOOL)accessInstanceVariablesDirectly; `（是否直接访问成员变量）方法。

若返回NO，则直接调用`- (nullable id)valueForUndefinedKey:;`(默认是抛出异常)。

若返回YES，按 `_key`、`_iskey`、`key`、`isKey`的顺序搜索成员名。

3.在第二步还没搜到的话就会调用`- (nullable id)valueForUndefinedKey:`方法。



#### 取值

1.按先后顺序搜索`getKey:`、`key`、`isKey`三个方法，若某一个方法被实现，取到的即是方法返回的值，后面的方法不再运行。如果是BOOL或者Int等值类型， 会将其包装成一个NSNumber对象。

2.若这三个方法都没有找到，则会调用`+ (BOOL)accessInstanceVariablesDirectly`方法判断是否允许取成员变量的值。

若返回NO，直接调用`- (nullable id)valueForUndefinedKey:(NSString *)key`方法，默认是奔溃。

若返回YES,会按先后顺序取`_key`、`_isKey`、 `key`、`isKey`的值。

3.返回YES时，`_key`、`_isKey`、 `key`、`isKey`的值都没取到，调用`- (nullable id)valueForUndefinedKey:(NSString *)key`方法。



#### 异常

1. 获取值时找不到key

\- (nullable id)valueForUndefinedKey:(NSString *)key;

2. 设值时找不到key

\- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key；

3. 给不能设置nil的属性设置了nil。



#### 非对象和自定义对象

KVC中返回的是一个id类型的对象，所以调用valueForKey:时如果是基本数据类型或者结构体，KVC会自动转成NSNumber类型或者NSValue类型，但是调用SetValue: forKey:时需要手动把基本数据类型或者结构体转成对象。





### KVO

[链接](https://www.jianshu.com/p/5477cf91bb32)

person 添加addObserver方法时，isa指针由之前的指向类对象变为指向NSKVONotifyin_Person对象。NSKVONotifyin_Person为Person 的子类，是在运行时产生的。

p1的setAge方法的实现由Person类方法中的setAge方法转换为了C语言的Foundation框架的_NSsetIntValueAndNotify函数

![img](https://upload-images.jianshu.io/upload_images/1434508-40e66a75b2c8cc8a.png?imageMogr2/auto-orient/strip|imageView2/2/w/1024)



1. iOS用什么方式实现对一个对象的KVO？（KVO的本质是什么？）
	答. 当一个对象使用了KVO监听，iOS系统会修改这个对象的isa指针，改为指向一个全新的通过Runtime动态创建的子类，子类拥有自己的set方法实现，set方法实现内部会顺序调用**willChangeValueForKey方法、原来的setter方法实现、didChangeValueForKey方法，而didChangeValueForKey方法内部又会调用监听器的observeValueForKeyPath:ofObject:change:context:监听方法。**
2. 如何手动触发KVO
	答. 被监听的属性的值被修改时，就会自动触发KVO。如果想要手动触发KVO，则需要我们自己调用**willChangeValueForKey和didChangeValueForKey**方法即可在不改变属性值的情况下手动触发KVO，并且这两个方法缺一不可。



### OC对象

[链接](https://www.jianshu.com/p/aa7ccadeca88)

OC对象主要可以分为三种

1. instance对象（实例对象）

	**instance对象就是通过类alloc出来的对象，每次调用alloc都会产生新的instance对象**

	信息包括 1. isa指针，2. 其他成员变量

2. class对象（类对象）

	**每一个类在内存中有且只有一个class对象**

	class对象在内存中存储的信息主要包括

	1. isa指针
	2. superclass指针
	3. 类的属性信息（@property），类的成员变量信息（ivar）
	4. 类的对象方法信息（instance method），类的协议信息（protocol）

	**成员变量的值时存储在实例对象中的，因为只有当我们创建实例对象的时候才为成员变赋值。但是成员变量叫什么名字，是什么类型，只需要有一份就可以了。所以存储在class对象中。**

	

3. meta-class对象（元类对象）

	**每个类在内存中有且只有一个meta-class对象。**存放类方法。

	meta-class对象和class对象的内存结构是一样的，但是用途不一样，在内存中存储的信息主要包括

	1. isa指针

	2. superclass指针

	3. 类的类方法的信息（class method）

	

	**meta-class对象和class对象的内存结构是一样的，所以meta-class中也有类的属性信息，类的对象方法信息等成员变量，但是其中的值可能是空的。**
		

1. 当对象调用实例方法的时候实例方法的信息是存在class中的，**instance的isa指向class，当调用对象方法时，通过instance的isa找到class，最后找到对象方法的实现进行调用。**
2. 当类对象调用类方法的时候，类方法是存储在meta-class元类对象中的。那么要找到类方法，就需要找到meta-class元类对象，而class类对象的isa指针就指向元类对象**class的isa指向meta-class
	当调用类方法时，通过class的isa找到meta-class，最后找到类方法的实现进行调用**

> **对isa、superclass总结**
>
> 1. instance的isa指向class
> 2. class的isa指向meta-class
> 3. meta-class的isa指向基类的meta-class，基类的isa指向自己
> 4. class的superclass指向父类的class，如果没有父类，superclass指针为nil
> 5. meta-class的superclass指向父类的meta-class，基类的meta-class的superclass指向基类的class
> 6. instance调用对象方法的轨迹，isa找到class，方法不存在，就通过superclass找父类
> 7. class调用类方法的轨迹，isa找meta-class，方法不存在，就通过superclass找父类





1. 一个NSObject对象占用多少内存？
	答：一个指针变量所占用的大小（64bit占8个字节，32bit占4个字节）

2. 对象的isa指针指向哪里？
	答：instance对象的isa指针指向class对象，class对象的isa指针指向meta-class对象，meta-class对象的isa指针指向基类的meta-class对象，基类自己的isa指针也指向自己。

3. OC的类信息存放在哪里？
	答：成员变量的具体值存放在instance对象。对象方法，协议，属性，成员变量信息存放在class对象。类方法信息存放在meta-class对象。



### class

Class对象其实是一个指向objc_class结构体的指针。因此我们可以说类对象或元类对象在内存中其实就是objc_class结构体。



