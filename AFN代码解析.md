1. 分类：

   <img src="https://tva1.sinaimg.cn/large/006tNbRwly1g9ynocioh5j308o0nzgoy.jpg" alt="image-20191216164359038"/>

   NSURLSession：

   Reachability: 可到达性

   Security：安全

   Serialization：序列化

   UIKit：对应页面的显示

   

   在头文件中内容：

   ![image-20191216165040733](https://tva1.sinaimg.cn/large/006tNbRwly1g9ynvb7sttj30q80kydkv.jpg)

   分为：

- 网络通信信息序列化/反序列化模块(AFURLRequestSerialization/AFURLResponseSerialization)

- 网络安全策略模块(AFSecurityPolicy)

- 网络监听模块(AFNetworkReachabilityManager) -- watch没有吧，所以不用

- 网络通信模块(AFURLSessionManager、AFHTTPSessionManager)

  `AFN`基于`NSURLSession`,核心是`AFURLSessionManager`。`AFHTTPSessionManager`继承自`AFURLSessionManager`.