# iOS13新特性

## 深夜模式

设置darkMode

```objective-c
if (@available(iOS 13.0, *)) {

​    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent animated:YES];

  } else {

​    // Fallback on earlier versions

​    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

  }
```





```objectivec
//在vc中重写方法
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor blackColor] : [UIColor whiteColor];
        NSLog(@"previousTraitCollection=%ld,overrideUserInterfaceStyle=%ld,self.traitCollection.userInterfaceStyle=%ld",previousTraitCollection.userInterfaceStyle,self.overrideUserInterfaceStyle,self.traitCollection.userInterfaceStyle);
    }
}
```



- UIColor 动态颜色

 在assets.xcassets中创建ColorSet,设置不同模式下的颜色。图片也可以设置



## 模态弹出presentViewcontroller

**先说适配,可以在公共父类的init中设置modalPresentationStyle 为 UIModalPresentationFullScreen**

**1.iOS13 presentViewcontroller样式发生变化**
UIModalPresentationStyle增加了一个UIModalPresentationAutomatic,并且在iOS13中是默认这个值,而之前默认的是UIModalPresentationFullScreen
UIModalPresentationAutomatic自带手势下拉dismiss



UIModalPresentationAutomatic和UIModalPresentationFullScreen不同,当A弹出B时,如果是UIModalPresentationFullScreen,A是会调用disappear相关生命周期方法的,B dismiss时,A也会调用appear相关方法,而UIModalPresentationAutomatic不会.



## KVC不允许使用私有方法

如textField,placehoderColor.设置成属性了



## 工程代理

添加SceneDelegate，主页面代理改变。



## Menus

![img](https://tva1.sinaimg.cn/large/006tNbRwly1ga6o2ctw25g307k0dcac5.gif)



![img](https://tva1.sinaimg.cn/large/006tNbRwly1ga6o2oy16aj309h0c074x.jpg)





## tableView 手势

添加双指活动编辑功能。

`tableView.allowsMultipleSelectionDuringEditing = true`

```swift
/// 是否允许多指选中
optional func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAtIndexPath indexPath: IndexPath) -> Bool

///多指选中开始，这里可以做一些UI修改，比如修改导航栏上按钮的文本
optional func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAtIndexPath indexPath: IndexPath) 
```



## 提醒事项

样式修改

## 取消流量下载限制

App Store150MB下载限制增加200MB。在这次的iOS13直接可以支持自定义设置了。

## 浏览器下载管理，自动解压

