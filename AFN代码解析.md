## 分类：

<img src="https://tva1.sinaimg.cn/large/006tNbRwly1g9ynocioh5j308o0nzgoy.jpg" alt="image-20191216164359038"/>

NSURLSession：对系统UrlSession进行进一步封装。核心为AFURLSessionManager,httpSession是对UrlSession的封装。

Reachability: 可到达性，网络状态相关的操作

Security：安全性相关操作接口

Serialization：序列化，数据解析

UIKit：对应页面的显示



## 代码解析

[链接]()

在头文件中内容：

![image-20191216165040733](https://tva1.sinaimg.cn/large/006tNbRwly1g9ynvb7sttj30q80kydkv.jpg)

分为：

- 网络通信信息序列化/反序列化模块(`AFURLRequestSerialization`/`AFURLResponseSerialization`)

- 网络安全策略模块(`AFSecurityPolicy`)

- 网络监听模块(`AFNetworkReachabilityManager`) -- watch没有吧，所以不用

- 网络通信模块(`AFURLSessionManager`、`AFHTTPSessionManager`)

  `AFN`基于`NSURLSession`,核心是`AFURLSessionManager`。`AFHTTPSessionManager`继承自`AFURLSessionManager`.



### 网络通信模块

```objective-c
 AFURLSessionManager实现以下委托方法：

 ###`NSURLSessionDelegate`

 -`URLSession：didBecomeInvalidWithError：`
 -`URLSession：didReceiveChallenge：completionHandler：`
 -`URLSessionDidFinishEventsForBackgroundURLSession：`

 ###`NSURLSessionTaskDelegate`

 -`URLSession：willPerformHTTPRedirection：newRequest：completionHandler：`
 -`URLSession：task：didReceiveChallenge：completionHandler：`
 -`URLSession：task：didSendBodyData：totalBytesSent：totalBytesExpectedToSend：`
 -`URLSession：task：needNewBodyStream：`
 -`URLSession：task：didCompleteWithError：`

 ###`NSURLSessionDataDelegate`

 -`URLSession：dataTask：didReceiveResponse：completionHandler：`
 -`URLSession：dataTask：didBecomeDownloadTask：`
 -`URLSession：dataTask：didReceiveData：`
 -`URLSession：dataTask：willCacheResponse：completionHandler：`

 ###`NSURLSessionDownloadDelegate`

 -`URLSession：downloadTask：didFinishDownloadingToURL：`
 -`URLSession：downloadTask：didWriteData：totalBytesWritten：totalBytesExpectedToWrite：`
 -`URLSession：downloadTask：didResumeAtOffset：expectedTotalBytes：`
```

属性：

- session ： 托管会话

- operationQueue ：运行委托回调的操作队列。

- responseSerializer：服务器发送的响应。为 AFJSONResponseSerializer 的实例。

- securityPolicy ：通过创建的会话使用的安全策略，以评估安全连接服务器信任。

- reachabilityManager ：网络可达性管理器。 默认是[AFNetworkReachabilityManager sharedManager].
- tasks: array 当前由托管会话运行的数据，上载和下载任务。
- dataTasks: array 当前数据任务管理。
- uploadTasks: 当前上传任务管理
- downloadTasks：当前下载任务
- completionQueue ：dispatch_queue_t 调度队列，默认为主队列
- completionGroup ：调度组，默认是一个私有调度组
- attemptsToRecreateUploadTasksForBackgroundSessions：当初始调用返回nil时是否尝试重试为后台会话创建上载任务。如果此属性为“ YES”，则AFNetworking将遵循Apple的建议尝试再次创建任务。









## AFN根据调用页面取消操作



[例子1](https://www.jianshu.com/p/faa1950814d0) : 网络请求添加监听对象监听释放。



## AFN断点续传



