一.+ (void)initialize 

概念：initialize在向类发送消息(比如初始化类的实例对象，调用类的方法)的时候调用一次。在类的第一个方法被调用前调用。initialize不是init。此类方法在第一次创建当前类对象（调用[[class alloc]init]）时被调用一次，此后不管创建多少当前类的对象都不会调用initialize方法。在程序运行的过程中，会为程序中的每个类调用一次initialize方法。在new的时候，initialize方法会在init之前先调用。调用的时间发生在当前类收到消息之前，当前类的父类接受到initialize之后。

子类：当前类A重写initialize方法，创建多个A对象。initialize方法只会被调用一次。生成当前类的子类B未重写initialize方法，创建多个子类B对象。initialize也会被调用一次。（注释：若只对子类B发送消息init时，（只创建B类对象）B的父类A会先接受到init的消息，并调用A的initialize为A类，随后会再调用一次A的initialize方法为B类。会调用两次A的initialize方法。）

分类：如果类B包含分类(叙述接上)，且分类B(test)重写了initialize方法，那么则会调用分类B(test)的 initialize 实现，而原类B的该方法实现不会被调用，这个机制同 NSObject 的其他方法(除 + (void)load 方法) 一样，即:如果原类同该类的分类包含有相同的方法实现，那么原类的该方法被隐藏而无法被调用。（分类会覆盖该类的方法，不影响对父类的调用）

父类A ：NSObject  重写+(void)initialize方法 

+ (void)initialize{   

if (self == [A class]) {   NSLog(@"for A initialize");   }

else if (self==[B class])    {    NSLog(@"for B  initialize");    }

} 

- (instancetype)init{    self = [super init];    if (self) {        NSLog(@"A init");    }    return self;}

子类B：A  未重写+(void)initialize方法

分类B（test）重写+(void)initialize方法

+ (void)initialize{    NSLog(@"%s",__FUNCTION__);}

调用1：既有父类又有子类

A *a1 =[[A alloc]init];  A *a2 =[[A alloc]init]; B *b1 =[[B alloc]init]; B *b2 =[[B alloc]init];B *b3 =[[B alloc]init];

分类已实现时输出：for A initialize，  A init，A init，A init ，+[B(test) initialize]，A init,A init ,A init 

未实现分类时输出：for A initialize，  A init，A init，A init ，for B  initialize，A init,A init ,A init 

调用2：只有子类

B *b1 =[[B alloc]init];  B *b2 =[[B alloc]init]; B *b3 =[[B alloc]init];

分类已实现时输出：for A initialize，+[B(test) initialize]，A init,A init ,A init 

未实现分类时输出：for A initialize，for B  initialize，A init,A init ,A init 
总结

1.分类中实现initialize方法，会覆盖原有类的initialize方法。

2.runtime运行时会先调用父类的initialize方法，在调用当前类的initialize方法。

3.+ (void)initialize 在类的第一个方法被调用前调用。

二.+(void)load 

重要：

1.+(void)load和+ (void)initialize只会被调用一次只相对于runtime运行时而言，即：程序启动时（load和initialize的隐式调用）。

2.runtime运行时下，+(void)load方法并不视为类的第一个方法。

3.+(void)load和+(void)initialize可当做普通类方法(Class Method)被调用，会触发initialize方法。即：显式调用如：[A load] or [A initialize]。

4.runtime运行时下，+(void)load方法中不能使用需要autorelease pool的代码。在隐式调用+(void)load方法时 自动释放池还未被创建。如需要autorelease pool的代码：[NSArray array];即使用时应用alloc.
依据Apple文档对于load方法的描述：

使用：每当将类或者类别（category）添加到运行时调用时，实现+(void)load方法可以在加载时，执行类的特定的行为。

调用时机：每个实现了+(void)load方法的类或者类别，一旦被加载，就会调动一次+(void)load方法；

调用顺序：1.子类的+(void)load方法是它的所有父类的+(void)load方法之后调用。2.分类的+(void)load方法是在当前类的+(void)load方法之后调用。

注意：混编时，实现了+(void)load方法的swift类桥接到Objective-C时，+(void)load方法不会被自动调用。

总结：

1.runtime运行时下（隐式调用），当前类未实现+(void)load方法，不会调用父类的方法。显式调用时，若父类实现了+(void)load方法，会调用父类的方法。

2.runtime运行时下（隐式调用）,当前类的多个分类都实现了+(void)load方法时。+(void)load方法会全部调用。

三.- (id)init 

init在类实例化（new）的时候就会调用一次

参考