### 自己写的view成员应该用weak还是strong

weak 和strong**都不会引起循环引用**

storyBoard用weak是苹果希望 **只有这些ui控件的父view来强引用他们**，而viewcontroller只需要强引用viewController.view成员，就可以**间接持**有是所有的ui控件 ， 有一个好处是，**在以前**，当系统收到memoryWaring时，会触发viewcontroller的viewDidUnload方法 ， 这样是弱引用方式，可以让整个view整体释放，方便整体重新构造。**但ios6就已经废弃**了viewDidUnload,苹果使用了更有效的方式来解决内存警告时的视图释放， 就是，**除非你特殊的操作view成员 ， viewcontroller.view的生命周期就跟viewcontroller是一样的了**。

现在可以用strong，好处：weak变量会**增加系统额外的维护开销**，**懒加载只能用strong**，weak需要注意  **赋值前，现将view加在父view上**，否则可能**刚创建过就被回收**了。



### 分类，类别（Category） 类扩展（Extension）

[原帖1](http://blog.csdn.net/u012946824/article/details/51799664)
分类 ，不能添加属性，添加属性了不能调用set get方法的，要添加了则新增set get方法
```
#import "ATestView+test.h"
//1.添加头文件
#import <objc/runtime.h>
//2.定义一个key
static NSString *nameWithSetterGetterKey = @"nameWithSetterGetterKey";   //定义一个key值

@implementation ATestView (test)
- (void)changeColorAgain {
    self.backgroundColor = [UIColor greenColor];
}
//3.设置set get方法
//设置属性要加set get 方法
- (void)setNameWithSetterGetter:(NSString *)nameWithSetterGetter {
    objc_setAssociatedObject(self, &nameWithSetterGetterKey, nameWithSetterGetter, OBJC_ASSOCIATION_COPY);//设置关联对象
}
- (NSString *)nameWithSetterGetter {
    return  objc_getAssociatedObject(self, &nameWithSetterGetterKey);//取关联对象
}
@end
```
类扩展
私有属性，不能被继承，类别内必须实现方法

为一个类添加额外的原来没有变量，方法和属性 
一般的类扩展写到.m文件中 
一般的私有属性写到.m文件中的类扩展中
```

#import "ATestView.h"

//这一块就是类扩展
@interface ATestView ()

@end

@implementation ATestView

@end
```

类别和类扩展的区别
①类别中原则上只能增加方法（能添加属性的的原因只是通过runtime解决无setter/getter的问题而已）； 
②类扩展不仅可以增加方法，还可以增加实例变量（或者属性），只是该实例变量默认是@private类型的（ 
用范围只能在自身类，而不是子类或其他地方）； 
③类扩展中声明的方法没被实现，编译器会报警，但是类别中的方法没被实现编译器是不会有任何警告的。这是因为类扩展是在编译阶段被添加到类中，而类别是在运行时添加到类中。 
④类扩展不能像类别那样拥有独立的实现部分（@implementation部分），也就是说，类扩展所声明的方法必须依托对应类的实现部分来实现。 
⑤定义在 .m 文件中的类扩展方法为私有的，定义在 .h 文件（头文件）中的类扩展方法为公有的。类扩展是在 .m 文件中声明私有方法的非常好的方式。

[原帖2](https://www.2cto.com/kf/201701/591328.html)
类别用于在不获悉、不改变原来代码的情况下往一个已经存在的类中添加新的方法，只需要知道这个类的公开接口，而不需要知道类的源代码。类别只能为已存在的类添加新的方法，而不能添加实例变量。类别扩展的新方法有更高的优先级，会覆盖同名的原类的已有方法。



### 类label 设置自动高度-intrinsicContentSize

类似于label，当没有给大小约束时，使控件自己知道自己多大

子方法中添加
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void) layoutSubviews
{
    [super layoutSubviews];
  
    if (!CGSizeEqualToSize(self.bounds.size, [self intrinsicContentSize]))
    {
        [self invalidateIntrinsicContentSize];
    }
}

- (CGSize)intrinsicContentSize
{
    CGSize intrinsicContentSize = self.contentSize;
    intrinsicContentSize.width = self.frame.size.width;
  
    NSLog(@"self.contentSize = %@",NSStringFromCGSize(self.contentSize));
    NSLog(@"self.bounds = %@",NSStringFromCGRect(self.bounds));
    if (intrinsicContentSize.height < _minHight) {
        intrinsicContentSize.height = _minHight;
    }
  
    return intrinsicContentSize;
}


invalidateIntrinsicContentSize 刷新自己的view大小，调用这个方法会自动调用 intrinsicContentSize，  修改intrinsicContentSize 函数，可以更改自己知道的自己的大小

链接：http://blog.csdn.net/hard_man/article/details/50888377
https://www.jianshu.com/p/69358b33e0f6


>还有当我们使用自己自定义的UICollectionView的时候，每当刷新数据调用reloadData()方法的时候：
>
>务必调用 collectionViewLayout.invalidateLayout()方法，不然可能会发生下面的错误
>
>UICollectionView received layout attributes for a cell with an index path that does not exist
