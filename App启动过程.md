## 1. App启动过程

[链接](https://zhuanlan.zhihu.com/p/28600469)

- 解析Info.plist

- - 加载相关信息，例如如闪屏
	- 沙箱建立、权限检查

- Mach-O加载

- - 如果是胖二进制文件，寻找合适当前CPU类别的部分
	- 加载所有依赖的Mach-O文件（递归调用Mach-O加载的方法）
	- 定位内部、外部指针引用，例如字符串、函数等
	- 执行声明为__attribute__((constructor))的C函数
	- 加载类扩展（Category）中的方法
	- C++静态对象加载、调用ObjC的 +load 函数

- 程序执行

- - 调用main()
	- 调用UIApplicationMain()
	- 调用applicationWillFinishLaunching