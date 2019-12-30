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