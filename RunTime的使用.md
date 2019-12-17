## 使用

1. 给分类添加属性。

  ```objective-c
  objc_getAssociatedObject(self,key);
  objc_setAssociatedObject(self, key, object,OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  ```





## message_send

1. 动态绑定

message_send 找不到对象，分为两种情况：

对象为空，则发送的消息时有效的，但不做任何处理

对象不为空，但找不到对应方法：崩溃



2. 消息转发机制：

