函数调用是要开辟内存的

死循环 死递归 



![image-20191217205544197](https://tva1.sinaimg.cn/large/006tNbRwly1ga00kndqrcj30ts0l4k06.jpg)

汇编 sp 栈顶

先压栈，再出栈

执行方法是在压栈

递归了的话 没到出栈就压栈 栈溢出



堆栈溢出：

<img src="https://tva1.sinaimg.cn/large/006tNbRwly1ga013fcxxzj30bs0p2t9i.jpg" alt="006tNbRwly1ga00ngxzy0j30bs0p2gpz" style="zoom:50%;" />

栈从上到下，堆从下到上 相遇了就堆栈溢出





hook  钩子 取到系统函数

埋点 crash收集

fishhook—是Facebook提供的一个动态修改链接mach-O文件的工具。利用MachO文件加载原理，通过修改懒加载和非懒加载两个表的指针达到C函数HOOK的目的。

fishhook不能获取自定义函数：

自定义函数：在复制到内存的镜像中，位置不确定

系统函数：在系统库里面 

系统能知道自定义函数能取到位置 ，系统函数在手机系统内存里面，系统不知到位置。

系统的pic技术：位置代码独立。运行时生成列表，存指针，在运行的时候动态链接加载marh-o的时候给指针赋值。符号表、符号、符号绑定。

![image-20191217211614946](https://tva1.sinaimg.cn/large/006tNbRwly1ga015yb9pvj31680pwdwb.jpg)

mark-o文件 氛围text-代码段，data-数据段



hook 注入代码