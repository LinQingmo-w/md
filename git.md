![git常用命令速查.png](http://upload-images.jianshu.io/upload_images/2773034-625981ef515681e2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

1. 建文件夹 git clone <远程连接地址>
2. 新文件夹的 git init 
3. git log 查看Log 

4. git branch -a 查看所有分支  远程的是红色的。本地的是黑色的 当前是绿色的
5. git checkout <远程分支名> -b <本地要起的分支名>
6. 最后查看下本地分支  是不是有了的

7. 放弃所有修改 git checkout .   放弃文件是 git checkout <文件名>
8. git fetch 获取远程分支

9. 创建远程分支
（1）git branch feature/1.15.13 //创建本地分支
（2）git checkout feature/1.15.13 //切换到本地分支
（3）git push --set-upstream origin feature/1.15.13 //提交本分支到远程 也可以直接在那个分支打 git push 会提示整个的话 然后复制下来运行就行

10. 合并分支
在目标分支 git merge feature/1.15.13 //合并feature/1.15.13到当前分支
然后再 git push

11. [暂存](http://blog.csdn.net/longxiaowu/article/details/26815433)
(1). 存储到暂存区 git stash 
(2).存储暂存区包括暂存信息 git stash save "信息" //注意 不能加-a  会把包括忽略的一起保存 会不能恢复    **要添加添加文件应该加 -u 不能是-a**
(3).查看暂存区内容 git stash list   会有标号
stash@{0}: WIP on feature/1.15.14: 854943b Merge branch 'feature/1.15.13'
stash@{1}: On feature/1.15.14: 搜索框
(4).暂存区恢复  git stash pop (同时删除暂存区的内容) git stash apply (暂存区内容保存)  git stash pop stash@{id} 后面可用加id
(5).删除暂存区  git stash drop stash@{0}  后面是暂存区标号  不加标号删除最上面一个 git  stash clear 清除所有内容

12. 放弃本地commit  
（1）git log 查看commit信息
（2）找到要撤销的commit 的前一个
（3)  git reset logId

13. 
1.git已track的文件脱离版本控制   
git rm - r -n —cached “*.DS_Store”//递归便利和预览
git rm -r —cached “*.DS_Store” //删除
添加.gitignore 控制我们需要忽略的文件
进入相关目录：
touch .gitignore 文件 rm 文件 删除它
vim .gitignore 文件  输入需要忽略的文件格式
//插入编辑：i  退出编辑 esc +:wq
git add .gitignore 添加到仓库本地
git commit - m “提交注释”

git commit --amend 修改上次commit注释内容

14. tag

  ```
  # git tag　　//查看tag #

  \# git tag test_tag c809ddbf83939a89659e51dc2a5fe183af384233　　　　//在某个commit 上打tag
  \# git tag
...
 \#git push origin test_tag　　　　//!!!本地tag推送到线上
...
  \#  git tag -d test_tag　　　　　　　　//本地删除tag
  \#  git push origin :refs/tags/test_tag　　　　//本地tag删除了，再执行该句，删除线上tag
  ```

 

15. svn转git
   如何将SVN仓库转换为Git仓库 
   按如下步骤操作就可以将SVN仓库完整的转换为Git仓库： 
   
   1) 将远程SVN仓库搬到本地(这一步主要是为了提高转换的速度，也可以忽略) 
    这里假设最终要转换的SVN仓库为file:///tmp/test-svn 
   
   2) 使用git svn clone命令开始转换 
      ` $ git svn clone file:///tmp/test-svn -T trunk -b branches -t tags `
     ` git svn clone `命令会把整个`Subversion`仓库导入到一个本地的Git仓库中。这相当于针对所提供的 URL 运行了两条命令`git svn init`加上`gitsvn fetch`。因Git需要提取每一个版本，每次一个，再逐个提交。对于一个包含成百上千次提交的项目，花掉的时间则可能是几小时甚至数天(如果你的SVN仓库是远程网络访问的，先执行上面第一步的操作还是有点好处的。不过项目通常提交次数都不少，漫长的等待是少不了的啦，慢慢等吧)。 
   
   `  -T trunk -b branches -t tags`告诉`Git`该`Subversion`仓库遵循了基本的分支和标签命名法则。如果你的主干(trunk，相当于Git里的master分支，代表开发的主线）、分支或者标签以不同的方式命名，则应做出相应改变。由于该法则的常见性，可以使用-s来代替整条命令，它意味着标准布局（s是Standard layout的首字母），也就是前面选项的内容。下面的命令有相同的效果：
   
   `  $ git svn clone file:///tmp/test-svn -s `
   注意本例中通过 git svn 导入的远程引用，Subversion的标签是当作远程分支添加的，而不是真正的Git标签。导入的Subversion仓库仿佛是有一个带有不同分支的tags远程服务器。用“$ git show-ref”就可以看到转换后Git仓库的相关情况，结果类似如下： 
   
   `$ git show-ref 
   1cbd4904d9982f386d87f88fce1c24ad7c0f0471 refs/heads/master 
   aee1ecc26318164f355a883f5d99cff0c852d3c4 refs/remotes/my-calc-branch 
   03d09b0e2aad427e34a6d50ff147128e76c0e0f5 refs/remotes/tags/2.0.2 
   50d02cc0adc9da4319eeba0900430ba219b9c376 refs/remotes/tags/release-2.0.1 
   4caaa711a50c77879a91b8b90380060f672745cb refs/remotes/tags/release-2.0.2 
   1c4cb508144c513ff1214c3488abe66dcb92916f refs/remotes/tags/release-2.0.2rc1 
   1cbd4904d9982f386d87f88fce1c24ad7c0f0471 refs/remotes/trunk `
   
   而普通的 Git 仓库是类似如下模样： 
   
   ` $ git show-ref 83e38c7a0af325a9722f2fdc56b10188806d83a1 refs/heads/master 
   3e15e38c198baac84223acfc6224bb8b99ff2281 refs/remotes/gitserver/master 
   0a30dd3b0c795b80212ae723640d4e5d48cabdff refs/remotes/origin/master 
   25812380387fdd55f916652be4881c6f11600d6f refs/remotes/origin/testing  `
   
   这里有两个远程服务器：一个名为gitserver，具有一个master分支；另一个叫origin，具有master和testing两个分支。 
   
   3) 获取SVN服务器的最新更新到转换后的Git仓库（这步通常在连续的转换过程中就没必要了） 
       `$ git svn rebase `
   
   4) 转换SVN仓库的svn:ignore属性到Git仓库的.gitignore文件 
      `$ git svn create-ignore `
   
   > 该命令自动建立对应的.gitignore文件，以便下次提交的时候可以包含它。如果在生成.gitignore文件前想先查看一下，运行命令“git svn show-ignore”即可。 
   
    5) 转换SVN的标签为Git标签 

 ```
$ cp -Rf .git/refs/remotes/tags/* .git/refs/tags/ 
$ rm -Rf .git/refs/remotes/tags 
 ```

> 该命令将原本以 tag/ 开头的远程分支的索引变成真正的（轻巧的）标签。 

    这个在Window下试过不行，报”cp: cannot stat `.git/refs/remotes/tags/*': No such file or directory“的错误，可以使用如下两个标准命令处理： 

```
$ git tag tagname tags/tagname     ----用指定的分支创建一个Git标签 
$ git branch -r -d tags/tagname    ----删除指定的远程分支 
```



​	6) 转换SVN的分支为Git分支 

    $ cp -Rf .git/refs/remotes/* .git/refs/heads/ 
    $ rm -Rf .git/refs/remotes 
​	该命令把refs/remotes下面剩下的索引变成Git本地分支 

​	7) 最后把转换后的本地Git仓库推到公共的Git服务器 

```
$ git remote add origin [远程Git服务器地址] 
$ git push origin master --tags 
```

> 所有的标签和主干现在都应该整齐干净的躺在新的Git服务器里了。如果要将分支也同步到远程Git服务器，将--tags改为--all。

16.
经常在宽带网络状况不佳的时候，访问互联网上的SVN库是一件极其痛苦的事情，更别说要查看版本库的日志信息了。此时如果可以将远程版本库整个同步到本地，然后所有操作都在本地的版本库上进行，好处就不用多说了。幸运的是SVN已经提供了相应的功能，具体操作步骤如下： 
1）在本地建立一个新的版本库： 
   ` svnadmin create D:\test `
2）创建钩子文件`pre-revprop-change.bat：`（windows环境里是D:\test\hooks\pre-revprop-change.bat） 文件中只需要一行内容即可“exit 0”
3）初始化同步操作： 
    `svnsync init file:///D:/test <远程SVN库的URL> `
    （如果需要用户名/密码，则按提示输入。成功后命令行将输出信息：复制版本 0 的属性） 

4）执行同步操作： 
    `svnsync sync file:///D:/test `
   （如果需要用户名/密码，则按提示输入。如果远程SVN库数据较多，需要慢慢等待） 
5）如果远程SVN库有了新的更新，只需重复执行步骤4即可。 


16. 修改分支名称

   ```
   git branch -m old_branch new_branch # Rename branch locally 
   git push origin :old_branch # Delete the old branch 
   git push --set-upstream origin new_branch # Push the new branch, set local branch to track the new remote
   ```

   

17. 移除未跟踪文件

   ```
   16. 用 git clean
   	//删除 untracked files
   	git clean -f
   	// 连 untracked 的目录也一起删掉
   	git clean -fd
   	// 连 gitignore 的untrack 文件/目录也一起删掉 （慎用，一般这个是用来删掉编译出来的 .o之类的文件用的）
   	git clean -xfd
   	// 在用上述 git clean 前，墙裂建议加上 -n 参数来先看看会删掉哪些文件，防止重要文件被误删
   	git clean -nxfd
   	git clean -nf
   	git clean -nfd
   ```

   

   