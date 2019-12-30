## 分类：

<img src="https://tva1.sinaimg.cn/large/006tNbRwly1g9ynocioh5j308o0nzgoy.jpg" alt="image-20191216164359038"/>

NSURLSession：对系统UrlSession进行进一步封装。核心为AFURLSessionManager,httpSession是对UrlSession的封装。

Reachability: 可到达性，网络状态相关的操作

Security：安全性相关操作接口

Serialization：序列化，数据解析

UIKit：对应页面的显示



## 代码解析

[链接](https://www.jianshu.com/p/89530e416b92)

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



## 3.0 2.0

3.0基于NSURLSession。AFURLSessionManager为对NSURLSession的封装。



区别：

1. AFNetworking在3.0版本中删除了基于 NSURLConnection API的所有支持。如果你的项目以前使用过这些API，建议您立即升级到基于 NSURLSession 的API的AFNetworking的版本。

2. AFNetworking 3.0现已完全基于NSURLSession的API，这降低了维护的负担，同时支持苹果增强关于NSURLSession提供的任何额外功能。

3. 可以结合MBProgressHUD，网络请求时间短的话，就可以不要显示HUD，提高用户体验，另外HUD也可以懒加载，全程只需要一个HUD即可。HUD内部有创建HUD对象时涉及到请求时间的类方法，在这个方法中如果请求时间小于某个值，就返回nil，即不显示HUD。此外AFN还有联网检测功能，每次请求网络之前先检测有没有网络，没有网络则提示用户（涉及到AFN和HUD的组合封装）



- 为什么af2.0有一个常驻现场，3.0没有，用什么实现了

NSURLConnection的一大痛点就是：发起请求后，这条线程并不能随风而去，而需要一直处于等待回调的状态。

功能不一样：AF3.0的operationQueue是用来接收NSURLSessionDelegate回调的，鉴于一些多线程数据访问的安全性考虑，设置了maxConcurrentOperationCount = 1来达到串行回调的效果。
而AF2.0的operationQueue是用来添加operation并进行并发请求的，所以不要设置为1。








最上层的是AFHTTPRequestOperationManager,我们调用它进行get、post等等各种类型的网络请求

然后它去调用AFURLRequestSerialization【seralz深】做request参数拼装。然后生成了一个AFHTTPRequestOperation实例，并把request交给它。然后把AFHTTPRequestOperation添加到一个NSOperationQueue中。

接着AFHTTPRequestOperation拿到request后，会去调用它的父类AFURLConnectionOperation的初始化方法，并且把相关参数交给它，除此之外，当父类完成数据请求后，它调用了AFURLResponseSerialization把数据解析成我们需要的格式（json、XML等等）。

最后就是我们AF最底层的类AFURLConnectionOperation，它去数据请求，并且如果是https请求，会在请求的相关代理中，调用AFSecurityPolicy做https认证。最后请求到的数据返回。



用NSURLConnection [kə'nekʃən]，我们为了获取请求结果有以下三种选择：

1.在主线程调异步接口

2.每一个请求用一个线程，对应一个runloop，然后等待结果回调。

3.只用一条线程，一个runloop，所有结果回调在这个线程上。





## AFN根据调用页面取消操作

### [例子1](https://www.jianshu.com/p/faa1950814d0) : 网络请求添加监听对象监听释放。

1. 设置一个obj，持有一个数组保存网络请求的任务，监听传来的对象的释放

```objective-c
	.h
	#import <Foundation/Foundation.h>
	
	@interface KVHttpResponseObject : NSObject
	
	@property (nonatomic, strong) NSMutableArray * httpTasks;
	
	@end
	
	.m
	#import "KVHttpResponseObject.h"
	
	@implementation KVHttpResponseObject
	
	- (instancetype)init {
	    if (self = [super init]) {
	        self.httpTasks = [NSMutableArray array];
	    }
	    return self;
	}
	
	- (void)dealloc {
	    //当该对象被释放时取消掉所有任务
	    if (self.httpTasks.count) {
	        for (id object in self.httpTasks) {
	            if ([object isKindOfClass:[NSURLSessionDataTask class]]) {
	                [((NSURLSessionDataTask*)object) cancel];   //取消任务
	            }
	        }
	    }
	}
	
	@end
```

2.给NSObject添加一个属性，即监听对象。就是给NSObject动态添加一个强引用属性，设置set,get方法

```objective-c
.h
#import <Foundation/Foundation.h>
#import "KVHttpResponseObject.h"

@interface NSObject (KVHttp)
//释放监听对象
@property (nonatomic, strong) KVHttpResponseObject * kvHttpObject;

@end

.m
#import "NSObject+KVHttp.h"
#import <objc/runtime.h>

@implementation NSObject (KVHttp)

- (KVHttpResponseObject*)kvHttpObject {
    KVHttpResponseObject * object = objc_getAssociatedObject(self, "kvHttpObject");
    return object;
}

- (void)setKvHttpObject:(KVHttpResponseObject *)kvHttpObject {
    objc_setAssociatedObject(self, "kvHttpObject", kvHttpObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
```


3. 网络请求中将释放对象引入，并给他添加一个监听对象，请求结束移除

```objective-c
+ (NSURLSessionDataTask*)getWithUrl:(NSString*)url params:(NSDictionary*)params object:(NSObject*)object handler:(KVHTTPResponseHandle)handler {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  /**重*/
    KV_WO(object, wobject);  //弱引用释放对象
    if (!wobject.kvHttpObject) {
        //为该释放对象添加一个监听释放过程的监听对象
        wobject.kvHttpObject = [[KVHttpResponseObject alloc] init];
    }
  //开始请求
    NSURLSessionDataTask * task = [[KVHttpTool sharedHttpTool].manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //成功处理
        /**重*/
        [wobject.kvHttpObject.httpTasks removeObject:task]; //监听对象移除该请求任务
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //处理回调结果
        [self handleHttpResponse:YES task:task responseObject:responseObject error:nil handler:handler];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error {
        //失败处理
        /**重*/
        [wobject.kvHttpObject.httpTasks removeObject:task]; //监听对象移除该请求任务
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //处理回调结果
        [self handleHttpResponse:NO task:task responseObject:nil error:error handler:handler];
    }];
    /**重*/
    [wobject.kvHttpObject.httpTasks addObject:task];    //监听对象添加该请求任务，如果释放对象释放了，那么监听对象会自动取消掉所持有的所有未完成请求任务
    return task;
}
                
```

4. 使用 ：    

```objective-c	
[KVHttpTool getWithUrl:@"自己的接口请求地址" params:param object:self handler:^(KVHttpResponseCode code, NSInteger statusCode, NSDictionary *responseHeaderFields, id responseObject) {}];
```




> 使用runtime动态添加属性
>
> 利用持有关系中页面delloc，强引用对象也会delloc的方式
>
> 需要做好内存管理保证对象能被释放-里面要用weakSelf.

### [例子2](https://blog.csdn.net/weixin_34077371/article/details/93068129): 在BaseViewController中保存

> 在baseViewController中设置数组保存请求，页面取消移除。
>
> 需要请求调用添加方法，移除方法

```objective-c
// 取消请求
// 仅仅是取消请求, 不会关闭session
[self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];

// 关闭session并且取消请求(session一旦被关闭了, 这个manager就没法再发送请求)
[self.manager invalidateSessionCancelingTasks:YES];
self.manager = nil;

// 一个任务被取消了, 会调用AFN请求的failure这个block
[task cancel];
```

[IMP] AFN对解决block的循环引用做了处理...一般不需要用weakSelf.

## AFN断点续传

[链接](https://www.jianshu.com/p/616ef23511f7)

> 断点下载是很常见的一个需求，AFN3.0 也为我们提供了下载的方法，但要实现断点下载，还需要我们自己另行处理。不过也可以用ASI下载，很方便。[Demo](https://github.com/YaoYaoX/BreakpointDownloadDemo)

##### 一、 AFN3.0 下载过程

1. 创建NSURLSessionDownloadTask：两种方式(简写，具体查看api)

	

	```css
	1. -[AFURLSessionManager downloadTaskWithRequest...]
	  普通下载
	2. -[AFURLSessionManager downloadTaskWithResumeData:resumeData...]：
	  断点下载，resumeData是关键，没有就不能
	```

2. 开始下载

	

	```css
	1. [downloadTask resume]
	2. 下载时，会在tmp文件中生成下载的临时文件，
	   文件名是CFNetworkDownload_XXXXXX.tmp，后缀由系统随机生成
	3. 下载完将临时文件移动到目的路径
	```

3. 暂停下载

	

	```bash
	1. [downloadTask suspend]
	2. 暂停后task依然有效，通过resume又可以恢复下载
	```

4. 取消下载任务：取消后，task无效，要想继续下载，需要重新创建下载任务

	

	```css
	1. [downloadTask  cancle]：普通取消，无断点信息
	2. [downloadTask cancelByProducingResumeData...]
	    1. 断点下载用，取消并返回断点信息，下次开启下载任务时传入  
	    2. 取消任务时，只有满足以下的各条件，才会产生resumeData
	       1. 自从资源开始请求后，资源未更改过
	       2. 任务必须是 HTTP 或 HTTPS 的 GET 请求
	       3. 服务器在response信息汇总提供了 ETag 或 Last-Modified头部信息
	       4. 服务器支持 byte-range 请求
	       5. 下载的临时文件未被删除
	```

##### 二、断点下载实现代码

1. 新建下载任务

	

	```objectivec
	+ (NSURLSessionDownloadTask *)downloadTaskWithUrl:(NSString *)url
	  destinationUrl:(NSString *)desUrl
	  progress:(void (^)(NSProgress *))progressHandler
	  complete:(MISDownloadManagerCompletion)completionHandler {
	    // 检错
	    if (!url || url.length < 1 || !desUrl || desUrl.length < 1) {
	        NSError *error = [NSError errorWithDomain:@"参数不全" code:-1000 userInfo:nil];
	        completionHandler(nil,nil,error);
	        return nil;
	    }
	    
	    // 参数
	    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	    NSURL *(^destination)(NSURL *, NSURLResponse *) =
	    ^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
	        return [NSURL fileURLWithPath:desUrl];
	    };
	    
	    // 1. 生成任务
	    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
	    NSData *resumeData = [self getResumeDataWithUrl:url];
	    if (resumeData) {
	        // 1.1 有断点信息，走断点下载
	        NSURLSessionDownloadTask *downloadTask =
	        [manager downloadTaskWithResumeData:resumeData
	                                   progress:progressHandler
	                                destination:destination
	                                completionHandler:completionHandler];
	        // 删除历史恢复信息，重新下载后该信息内容已不正确，不再使用，
	        [self removeResumeDataWithUrl:url];
	        return downloadTask;
	    } else {
	        // 1.2 普通下载
	        NSURLSessionDownloadTask *downloadTask =
	        [manager downloadTaskWithRequest:request
	                                progress:progressHandler
	                             destination:destination
	                       completionHandler:completionHandler];
	        
	        return downloadTask;
	    }
	}
	```

2. 开始

	

	```csharp
	 + (void)startDownloadTask:(NSURLSessionDownloadTask *) downloadTask {
	     [downloadTask resume];
	 }
	```

3. 暂停

	

	```csharp
	 + (void)suspendDownloadTask:(NSURLSessionDownloadTask *) downloadTask {
	     [downloadTask suspend];
	 }
	```

4. 取消

	

	```objectivec
	+ (void)cancleDownloadTask:(NSURLSessionDownloadTask *) downloadTask {
	     __weak typeof(task) weakTask = task;
	     [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
	         // 存储resumeData，以便一次进行断点下载
	         [YYDownloadManager saveResumeData:resumeData withUrl:weakTask.currentRequest.URL.absoluteString];
	     }];
	 }
	```

5. 断点信息存储：代码太多，只列个思路供参考，需要的可以查看[Demo](https://github.com/YaoYaoX/BreakpointDownloadDemo)

	

	```objectivec
	 1. 随机为resumeData分配一个文件名并储存到本地
	 2. 用一个map文件记录特定url对应的resumeData位置，以便查找
	
	 + (void)saveResumeData:(NSData *)resumeData withUrl:(NSString *)url{
	     // 存储resumeData
	 }
	 + (NSData *)getResumeDataWithUrl:(NSString *)url {
	     // 获取resumeData
	 }
	 + (void)removeResumeDataWithUrl:(NSString *)url {
	     // resumeData无效之后应该删除
	 }
	```

##### 三、问题及解决方案：获取resumeData

> 场景：以上的下载过程，只适合用户手动暂停的场景，当出现意外情况的时候，比如好奇点了小飞机🤡，手一抖kill掉了app💩，将无法获取到resumeData，也就无法断点下载，若刚好碰到下载一个超大的文件，那也就无奈了😹😹😹....用户当然也无法容忍这种情况发生。

> 解决方案：创建下载任务时，只提供了传入resumeData进行断点下载的方法，这大大简化了断点下载的过程，但同时又造成了很大的不便，当没有resumeData时，便无法断点下载，所以出现问题的解决办法就是获取resumeData。

###### 1. 网络中断



```objectivec
1. downloadTask会中断，并返回错误信息，任务不能resume，若要继续需重建任务
2. 这种情况，查看错误信息会发现，里面有携带resumeDat
3. 那这就好办了，拿到resumeData并保存起来
4. 在(第一步)新建downloadTask时，有传入completionHandler，我们对其做一层处理
  
// 1.3 下载完成处理
MISDownloadManagerCompletion completeBlock =
^(NSURLResponse *response, NSURL *filePath, NSError *error) {
     // 任务完成或暂停下载
     if (!error || error.code == -999) {
        // 调用cancle的时候，任务也会结束，并返回-999错误，
        // 此时由于系统已返回resumeData，不另行处理了
        if (!error) {
            // 任务完成，移除resumeData信息
            [self removeResumeDataWithUrl:response.URL.absoluteString];
         }
         if (completionHandler) {
            completionHandler(response,filePath,error);
          }
      } else  {
          // 部分网络出错，会返回resumeData
          NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
          [self saveResumeData:resumeData withUrl:response.URL.absoluteString];  
          if (completionHandler) {
              completionHandler(response,filePath,error);
           }
       }
 };
```

###### 2. 意外kill掉了app

1. 这种情况不好获取resumeData，也曾做过尝试，监听UIApplicationWillTerminateNotification的通知，在app要结束的时候获取resumeData并保存，但现实还是比较残酷，由于时间太短resumeData无法保存成功，不可行

2. 既然resumeData这个东西神奇，那么从它下手，对其解析成字符串看是否发现什么有用的东西

	

	```xml
	这就是解析结果
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
	    <key>NSURLSessionDownloadURL</key>
	         <string>http://downloadUrl</string>
	   <key>NSURLSessionResumeBytesReceived</key>
	         <integer>1474327</integer>
	   <key>NSURLSessionResumeCurrentRequest</key>
	        <data>
	           ......
	        </data>
	   <key>NSURLSessionResumeEntityTag</key>
	        <string>"XXXXXXXXXX"</string>
	   <key>NSURLSessionResumeInfoTempFileName</key>
	        <string>CFNetworkDownload_XXXXX.tmp</string>
	   <key>NSURLSessionResumeInfoVersion</key>
	       <integer>2</integer>
	  <key>NSURLSessionResumeOriginalRequest</key>
	        <data>
	         .....
	      </data>
	   <key>NSURLSessionResumeServerDownloadDate</key>
	           <string>week, dd MM yyyy hh:mm:ss </string>
	</dict></plist>
	```

	1. 上面就是解析resumeData之后的数据，其实就是一个plist文件，里面信息包括了**下载URL、已接收字节数、临时的下载文件名(文件默认存在tmp文件夹中)、当前请求、原始请求、下载事件、resumeInfo版本、EntityTag**这些数据
	2. iOS8生成的resumeData稍有不同，没有NSURLSessionResumeInfoTempFileName字段，有NSURLSessionResumeInfoLocalPath，记录了完整的tmp文件地址

3. 回顾一下断点下载实际所需要的几要素

	

	```undefined
	1. 下载url
	2. 临时文件：即未完成的文件，断点下载开始后，需要继续将剩余文件流导入到临时文件尾部
	3. 文件开始位置：即临时文件大小，用于告诉服务器从哪块开始继续下载
	```

4. 🤓🤓🤓从2、3可以发现，resumeData其实就是一个包含了断点下载所需数据的一个plist文件...那就有思路了，何不尝试自己建一个resumeData呢？

5. 尝试：按照上面resumeData的格式手动建一个plist文件，但只保留NSURLSessionDownloadURL、NSURLSessionResumeBytesReceived、NSURLSessionResumeInfoTempFileName三个字段，下载时加载该文件当成resumeData传入，开始下载任务........哈哈哈，竟然能成功进行断点下载

6. 解决方案：分析后，发现可以自己伪造一个resumeData进行断点下载，只要拿到关键的几个数据

	1. 下载url：很方便能拿到
	2. 临时文件的path：由于其是系统自动下载，要拿到也需费一番功夫，地址隐藏在创建好的NSURLSessionDownloadTask对象中
	3. 已接收字节数：需拿到临时文件的字节数



```objectivec
代码实现

1.创建好普通下载任务后(非断点下载任务)，
  从NSURLSessionDownloadTask中获取临时文件名，
  并存入到tempFile的map文件中

{       
    //****创建普通task时多加一步骤：获取tmp文件名并保存****
    // 1.2 创建普通下载任务
    downloadTask = [manager downloadTaskWithRequest:request
                                           progress:progressHandler
                                        destination:destination
                                  completionHandler:completeBlock];
    // 1.3 获取临时文件名，并保存
    NSString *tempFileName = [self getTempFileNameWithDownloadTask:downloadTask];
    [self saveTempFileName:tempFileName withUrl:url];
}

2. 获取临时文件名的代码
+ (NSString *)getTempFileNameWithDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
     //NSURLSessionDownloadTask --> 属性downloadFile：__NSCFLocalDownloadFile --> 属性path
     NSString *tempFileName = nil;

     // downloadTask的属性(NSURLSessionDownloadTask) dt
     unsigned int dtpCount;
     objc_property_t *dtps = class_copyPropertyList([downloadTask class], &dtpCount);
     for (int i = 0; i<dtpCount; i++) {
        objc_property_t dtp = dtps[i];
        const char *dtpc = property_getName(dtp);
        NSString *dtpName = [NSString stringWithUTF8String:dtpc];
                    
        // downloadFile的属性(__NSCFLocalDownloadFile) df
        if ([dtpName isEqualToString:@"downloadFile"]) {
            id downloadFile = [downloadTask valueForKey:dtpName];
            unsigned int dfpCount;
            objc_property_t *dfps = class_copyPropertyList([downloadFile class], &dfpCount);
            for (int i = 0; i<dfpCount; i++) {
                objc_property_t dfp = dfps[i];
                const char *dfpc = property_getName(dfp);
                NSString *dfpName = [NSString stringWithUTF8String:dfpc];
                // 下载文件的临时地址
                if ([dfpName isEqualToString:@"path"]) {
                    id pathValue = [downloadFile valueForKey:dfpName];
                    NSString *tempPath = [NSString stringWithFormat:@"%@",pathValue];
                    tempFileName = tempPath.lastPathComponent;
                    break;
                 }
              }
              free(dfps);
              break;
          }
      }
      free(dtps);
      return tempFileName;
   }

3. 获取resumeData过程稍微调整
   1. 创建断点下载任务时，根据resumeDataMap找到resumeData，
   2. 若没发现resumeData，则根据tempFileMap的信息找到临时文件，
      获取其大小，然后尝试手动建一个resumeData，并加载到内存中
   3. 若没发现临时文件，则不创建resumeData，建立普通下载任务

/// 手动创建resume信息
+ (NSData *)createResumeDataWithUrl:(NSString *)url {
    if (url.length < 1) {
        return nil;
    }
                
    // 1. 从map文件中获取resumeData的name
    NSMutableDictionary *resumeMap = [NSMutableDictionary dictionaryWithContentsOfFile:[self resumeDataMapPath]];
    NSString *resumeDataName = resumeMap[url];
    if (resumeDataName.length < 1) {
        resumeDataName = [self getRandomResumeDataName];
        resumeMap[url] = resumeDataName;
        [resumeMap writeToFile:[self resumeDataMapPath] atomically:YES];
    }
                
     // 2. 获取断点下载的参数信息
     NSString *resumeDataPath = [self resumeDataPathWithName:resumeDataName];
     NSDictionary *tempFileMap = [NSDictionary dictionaryWithContentsOfFile:[self tempFileMapPath]];
     NSString *tempFileName = tempFileMap[url];
     if (tempFileName.length > 0) {
         NSString *tempFilePath = [self tempFilePathWithName:tempFileName];
         NSFileManager *fileMgr = [NSFileManager defaultManager];
        if ([fileMgr fileExistsAtPath:tempFilePath]) {
            // 获取文件大小
            NSDictionary *tempFileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:tempFilePath error:nil ];
            unsigned long long fileSize = [tempFileAttr[NSFileSize] unsignedLongLongValue];
                        
            // 3. 手动建一个resumeData
            NSMutableDictionary *fakeResumeData = [NSMutableDictionary dictionary];
            fakeResumeData[@"NSURLSessionDownloadURL"] = url;
            // ios8、与>ios9方式稍有不同
            if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_9_0) {
               fakeResumeData[@"NSURLSessionResumeInfoTempFileName"] = tempFileName;
            } else {
               fakeResumeData[@"NSURLSessionResumeInfoLocalPath"] = tempFilePath;
            }
            fakeResumeData[@"NSURLSessionResumeBytesReceived"] = @(fileSize);
            [fakeResumeData writeToFile:resumeDataPath atomically:YES];
                        
            // 重新加载信息
            return [NSData dataWithContentsOfFile:resumeDataPath];
         }
     }
     return nil;
 }
```

#### 四、其他

1. Demo中的测试地址
	是GitHub Desktop的下载地址，支持断点下载、下载完后打开文件可用于检验文件是否完整；文件比较大，可以模拟各个过程
2. 既然可以自己造一个resumeData，为什么还用系统返回的数据？
	自己造的毕竟不规范，能用系统提供的尽量用系统提供的，也为了减少未知的错误

#### 五、更新

[iOS后台下载、断点下载](https://blog.csdn.net/ssyyjj88/article/details/72466155)：里面详细介绍了如何在app被kill掉了之后如何恢复下载


