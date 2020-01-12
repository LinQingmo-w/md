## 使用

1. 给分类添加属性。

  ```objective-c
  objc_getAssociatedObject(self,key);
  objc_setAssociatedObject(self, key, object,OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  ```



2. 反射

	获取类别的类别，方法，根据方法名转义。动态设置属性。

## message_send

1. 动态绑定

message_send 找不到对象，分为两种情况：

对象为空，则发送的消息时有效的，但不做任何处理

对象不为空，但找不到对应方法：崩溃



2. 消息转发机制：

	调用方法时，先消息传递，没搜到再转发，没有转发就用崩溃。
	消息传递：分类(先缓存表后方法表)->当前类->父类->NSObject
	消息转发：动态方法解析->备用接收者->完整消息转发

	![img](https://upload-images.jianshu.io/upload_images/5417491-8a03f597e0e28ea4.png?imageMogr2/auto-orient/strip|imageView2/2/w/1039)

OC中任何方法的调用，本质都是发送消息.

**@selector (SEL)：是一个SEL方法选择器。**SEL其主要作用是快速的通过方法名字查找到对应方法的函数指针，然后调用其函数。SEL其本身是一个Int类型的地址，地址中存放着方法的名字。

 每个类都有一个方法列表MethodList,保存类中的方法。根据SEL传入的方法编号找到方法。

内部动态查找方法：

NSObject包含的信息

```cpp
struct objc_class {
  Class isa; // 指向metaclass
  
  Class super_class ; // 指向其父类
  const char *name ; // 类名
  long version ; // 类的版本信息，初始化默认为0，可以通过runtime函数class_setVersion和class_getVersion进行修改、读取
  long info; // 一些标识信息,如CLS_CLASS (0x1L) 表示该类为普通 class ，其中包含对象方法和成员变量;CLS_META (0x2L) 表示该类为 metaclass，其中包含类方法;
  long instance_size ; // 该类的实例变量大小(包括从父类继承下来的实例变量);
  struct objc_ivar_list *ivars; // 用于存储每个成员变量的地址
  struct objc_method_list **methodLists ; // 与 info 的一些标志位有关,如CLS_CLASS (0x1L),则存储对象方法，如CLS_META (0x2L)，则存储类方法;
  struct objc_cache *cache; // 指向最近使用的方法的指针，用于提升效率；
  struct objc_protocol_list *protocols; // 存储该类遵守的协议
}
```



**实例方法`[p eat];`底层调用`[p performSelector:@selector(eat)];`方法，编译器在将代码转化为`objc_msgSend(p, @selector(eat));`**

**在`objc_msgSend`函数中。首先通过`p`的`isa`指针找到`p`对应的`class`。在`Class`中先去`cache`中通过`SEL`查找对应函数`method`，如果找到则通过`method`中的函数指针跳转到对应的函数中去执行。**

**若`cache`中未找到。再去`methodList`中查找。若能找到，则将`method`加入到`cache`中，以方便下次查找，并通过`method`中的函数指针跳转到对应的函数中去执行。**

**若`methodlist`中未找到，则去`superClass`中查找。若能找到，则将`method`加入到`cache`中，以方便下次查找，并通过`method`中的函数指针跳转到对应的函数中去执行。**



runtime交换方法

1. 添加分类：需要每次导入头文件，方法替换。

2. 方法交换，只交换一次，在load方法中交换。

	```objective-c
	+(void)load
	{
	    // 获取要交换的两个方法
	    // 获取类方法  用Method 接受一下
	    // class ：获取哪个类方法 
	    // SEL ：获取方法编号，根据SEL就能去对应的类找方法。
	    Method imageNameMethod = class_getClassMethod([UIImage class], @selector(imageNamed:));
	    // 获取第二个类方法
	    Method xx_ccimageNameMrthod = class_getClassMethod([UIImage class], @selector(xx_ccimageNamed:));
	    // 交换两个方法的实现 方法一 ，方法二。
	    method_exchangeImplementations(imageNameMethod, xx_ccimageNameMrthod);
	    // IMP其实就是 implementation的缩写：表示方法实现。
	}
	```

本质是交换方法指针。



#### 动态添加方法：

懒加载机制，而当找不到对应的方法时就会来到拦截调用，在找不到调用的方法程序崩溃之前调用的方法。
当调用了没有实现的对象方法的时，就会调用**`+(BOOL)resolveInstanceMethod:(SEL)sel`**方法。



```objectivec
+(BOOL)resolveInstanceMethod:(SEL)sel
{
    // 动态添加eat方法
    // 首先判断sel是不是eat方法 也可以转化成字符串进行比较。    
    if (sel == @selector(eat)) {
    /** 
     第一个参数： cls:给哪个类添加方法
     第二个参数： SEL name:添加方法的编号
     第三个参数： IMP imp: 方法的实现，函数入口，函数名可与方法名不同（建议与方法名相同）
     第四个参数： types :方法类型，需要用特定符号，参考API
     */
      class_addMethod(self, sel, (IMP)eat , "v@:");
        // 处理完返回YES
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}
```

class_addMethod中的四个参数。第一，二个参数比较好理解，重点是第三，四个参数。

1. cls : 表示给哪个类添加方法，这里要给Person类添加方法，self即代表Person。
2. SEL name : 表示添加方法的编号。因为这里只有一个方法需要动态添加，并且之前通过判断确定sel就是eat方法，所以这里可以使用sel。
3. IMP imp : 表示方法的实现，函数入口，函数名可与方法名不同（建议与方法名相同）需要自己来实现这个函数。每一个方法都默认带有两个隐式参数
	**self : 方法调用者 _cmd : 调用方法的标号**，可以写也可以不写。



4. types : 表示方法类型，需要用特定符号。系统提供的例子中使用的是**`"v@:"`**，我们来到API中看看**`"v@:"`**指定的方法是什么类型的。



#### **forwardInvocation -备援接受者**

加入对象A无法处理消息fun，而对象B可以处理，此时A已经继承于类C，所以此时A不能再继承B。我们可以用消息转发的方式，来将消息转发给能够处理fun消息的对象B。

 **forwardInvocation**：方法，此方法继承与NSObject。不过NSObject中此方法的实现，只是简单的调用了doesNotRecognizeSelector:

我们要做的是重写需要转发消息的类A的forwardInvocation方法，以实现将消息转发给能处理fun消息的对象。

```objective-c
 - (void)forwardInvocation:(NSInvocation *)anInvocation {
 	if ([B respondsToSelector:[anInvocation selector])
 		[anInvocation B]; 
 	else 
 	[super forwardInvocation:anInvocation];
 } 
```



还有关键一步，是重写methodSignatureForSelector方法，此方法是在向对象发送不能处理的消息的时候调用的，此方法可判断消息fun是否有效注册。如果注册过fun，那么则返回fun消息的地址之类的信息，如果无效则返回nil，那么就crash掉。所以我们要把fun消息注册为一个有效的。



```objective-c
 - (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
     NSMethodSignature* signature = [super methodSignatureForSelector:selector];
     
     if (!signature)//如果父类中无注册fun消息，那么将B注册
         signature = [B methodSignatureForSelector:selector];
     
     return signature;
 }
```



这样一来，消息fun将被转发至B。

我们来说一下向一个对象发送消息后，系统的处理流程

1.首先发送消息[A fun];

2.系统会检查A能否响应这个fun消息，如果能响应则A响应

3.如果不能响应，则调用methodSignatureForSelector:来询问这个消息是否有效，包括去父类中询问。

4.接着调用forwardInvocation:此时步骤三返回nil或者可以处理消息的消息地址。如果nil则crash，如果有可以处理fun消息的地址，那么转发成功。



间接转发



#### 动态添加属性

给属性赋值其实就是属性指向一块

可以使用静态变量，或者绑定动态方法。**`objc_setAssociatedObject`**



### 字典转模型 kvc

KVC：KVC字典转模型实现原理是遍历字典中所有Key，然后去模型中查找相对应的属性名，要求属性名与Key必须一一对应，字典中所有key必须在模型中存在。
RunTime：RunTime字典转模型实现原理是遍历模型中的所有属性名，然后去字典查找相对应的Key，也就是以模型为准，模型中有哪些属性，就去字典中找那些属性。







## 缓存 cache_t

从源码中可以看出`bucket_t`中存储着`SEL`和`_imp`，通过`key->value`的形式，以`SEL`为`key`，`函数实现的内存地址 _imp`为`value`来存储方法。



## isKindOfClass isMemberOfClass

```objectivec
- (BOOL)isMemberOfClass:(Class)cls {
   // 直接获取实例类对象并判断是否等于传入的类对象
    return [self class] == cls;
}

- (BOOL)isKindOfClass:(Class)cls {
   // 向上查询，如果找到父类对象等于传入的类对象则返回YES
   // 直到基类还不相等则返回NO
    for (Class tcls = [self class]; tcls; tcls = tcls->superclass) {
        if (tcls == cls) return YES;
    }
    return NO;
}
```



![img](https://tva1.sinaimg.cn/large/006tNbRwly1gab2oqjlfrj30cm0d70uh.jpg)



>  **对isa、superclass总结**
>
> 1. instance的isa指向class
> 2. class的isa指向meta-class
> 3. meta-class的isa指向基类的meta-class，基类的isa指向自己
> 4. class的superclass指向父类的class，如果没有父类，superclass指针为nil
> 5. meta-class的superclass指向父类的meta-class，基类的meta-class的superclass指向基类的class
> 6. instance调用对象方法的轨迹，isa找到class，方法不存在，就通过superclass找父类
> 7. class调用类方法的轨迹，isa找meta-class，方法不存在，就通过superclass找父类



#### weak表

`Runtime`维护了一个`Weak`表，用于存储指向某个对象的所有`Weak`指针。`Weak`表其实是一个哈希表，**Key是所指对象的地址，Value是Weak指针的地址（这个地址的值是所指对象的地址）的数组。**
在对象被回收的时候，经过层层调用，会最终触发下面的方法将所有`Weak`指针的值设为nil。

`weak` 的实现原理可以概括一下三步：

1、初始化时：`runtime`会调用`objc_initWeak`函数，初始化一个新的`weak`指针指向对象的地址。

2、添加引用时：`objc_initWeak`函数会调用 `objc_storeWeak() `函数， `objc_storeWeak() `的作用是更新指针指向，创建对应的弱引用表。

3、释放时，调用`clearDeallocating`函数。`clearDeallocating`函数首先根据对象地址获取所有`weak`指针地址的数组，然后遍历这个数组把其中的数据设为nil，最后把这个`entry`从`weak`表中删除，最后清理对象的记录

