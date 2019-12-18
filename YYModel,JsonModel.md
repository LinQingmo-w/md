## YYModel

[链接](https://www.jianshu.com/p/62d4f86c7482)

使用runtime里面的动态方法表，去取属性。

class与metalClass: class指向的是一个结构体指针。包含isa, ivarlist methodlist cache,protocolList. isa指针指向类。

isa指针指向元类，到最顶层指向自己。superClass指向父类，如果到最顶层，则为null。

cash缓存最近使用的方法。找一个方法会先在cache中找，没有才去methodLists中找。

元类：想这个类发送消息-调用方法。即类方法。成员变量ivar。方法列表：methodLists。

协议列表：添加协议，返回类是否实现指定的协议。返回类实现的协议列表。

NSScanner:在字符串中扫描指定的字符

messageSend 设置和获取属性值均通过objc_msgSend



### 实现

- _YYModelMeta  完成model属性，方法，实例变量的解析，炳胜车与数据源相对应的字典映射

- YYClassInfo  存储Model解析后的各种信息
- YYClassMethodInfo  存储方法的信息
- YYClassIvarInvo  存储实例变量的信息
- YYClassPropertyInfo  存储属性的信息
- _YYModelPropertyMeta  包含了属性的信息和设置属性时所需的信息，由上述解析得到信息和自定义的信息和成。



### 解析过程

​	调用方法进行初始化的时候，YYModelMeta将会为我们完成解析的工作，获取model类的方法、属性、实例变量信息，保存在YYClassInfo中

​	解析前会检查是否有缓存。只有设置了 YYClassInfo 的 needUpdate 才会进行新的解析。。

​	生成映射关系，建立与数据源之间的映射关系，即生成了一个以数据源子的的key为key，以属性值为值的maper。

​	用modelSetWithDictionary完成属性值的设置。







## JsonModel

class_copyPropertyList得到类的属性列表，在遍历列表，用property_getAttributes得到每个属性的类型，最后用kvc，接可以得到所有的值。

3.对获得的JSON进行类型处理。



- 在JSON中为NSNumer,而propertytype为NSString,这种情况很常见。我们就需要处理一下，当propertytype为NSString,而在JSON中为NSNumber,就把NSNumber转化为NSString。
- Readonly不需要赋值
- nil处理
- 可变和不可变处理
- 模型就需要递归处理
- NSString -> NSURL
- 字符串转BOOL
- 还有一些其他处理，以上的处理中也不是每个第三方都进行处理了



重点：取属性（属性列表）。kvc 匹配数据。中间有你感到反射机制

