1. 调试：p/po

	p:打印值

	po: 打印description方法

2. Buildtime issue , Runtime issue

	Buildtime issue:编译时的错误,警告，错误，静态分析（未初始化变量，未使用数据，API使用错误（如未调用super））

	Runtime issue:运行时错误。线程问题、UI布局和渲染问题、内存问题。

3. app启动优化

	1. 查看分析日志，添加时间变量，查看启动时间。DYLD_PRINT_STATISTICS
	2. 出现问题：动态加载库，重定位/绑定，对象初始化
	3. 解决：减少动态累（苹果建议不多于6个），减少累数量（合并或删除，会加快动态链接，重定位和绑定会快）,用initialize替换load方法或load方法延迟调用（减少初始化时间）

4. 检查循环引用

	1. xcode的memory debug cgaph,在调试栏
	2. runtime issue
	3. leak - cellTree.建议在display中候选separate by thread 和 hide system libraries，会隐藏系统和应用自身的调用路径。

5. EXD_BAD_ACCESS

	1. 全局断点：效果一般

	2. 重写object的respondsToSelecotr: 一般，并要在每个类单独排查，不易操作

	3. zombie 和address sanitizer.在edit scheme

		