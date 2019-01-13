---
title: Objective C 特性
date: 2019-01-11 14:41:50
tags:
  - ios
categories:
  - Objective c
author: 奎宇

---
# Objective C 特性
## 分类
功能
- 生命私有方法
- 分解体积庞大的类文件
- 把Framework的私有方法公开化

特点
- 运行时决议，编写完成后没有附加到宿主类中，没有对应的方法，运行时添加到响应的宿主上
- 可以为系统类添加分类
- 分类添加的方法回覆盖原类方法（原类方法依然存在）
- 同名方法谁能生效取决于编译顺序
- 名字相同的分类会引起编译器报错

分类中可以添加
- 实例方法
- 类方法
- 类属性（只是声明了set get 方法，没有相应的变量）
- 协议
<!--more-->
分类的源码，实际是创建的分类文件
```
struct category_t {
    const char *name;//分类的名称 
    classref_t cls;//所属宿主类
    struct method_list_t *instanceMethods;//实例方法列表
    struct method_list_t *classMethods;//类方法列表
    struct protocol_list_t *protocols;//协议列表
    struct property_list_t *instanceProperties;//实例属性的列表，没有实例变量的列表。
    // Fields below this point are not always present on disk.
    struct property_list_t *_classProperties;

    method_list_t *methodsForMeta(bool isMeta) {
        if (isMeta) return classMethods;
        else return instanceMethods;
    }

    property_list_t *propertiesForMeta(bool isMeta, struct header_info *hi);
};
```

## 加载调用栈
![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/Objective-C/objectloadstate.png)

![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/Objective-C/loadmaps.png)

## 关联对象
添加成员成员变量（关联对象）
![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/Objective-C/associatedmap.png)
实际效果
![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/Objective-C/associatedresult.png)


## 扩展
用处
- 声明私有属性
- 声明私有方法
- 声明私有成员变量

特点
- 编译时决议
- 只以声明的形式存在，多少情况下寄生于宿主的 .m 中
- 不能为系统类添加扩展

## 代理
是代理模式
可以定义方法也可以定义属性

![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/Objective-C/delegate.png)

## 通知

- 是使用`观察者模式`来实现跨层传递消息
- 传递方式为一对多

![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/Objective-C/associatedmap.png)

通知机制的自实现
![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/Objective-C/notiimplementation.png)

## KVO

- KVO 是 key-value observing 缩写
- KVO 是 Objective-C对`观察者模式`的实现
- KVO 使用了`isa`混写(isa-swizzling)来实现

特点
- 使用setter 方法改变值kvo 才能生效
- 使用setValue:forkey:改变值KVO 会生效
- 成员变量直接修改必须手动添加KVO 才生效

## KVC

- `- (nullable id)valueForKey:(NSString *)key;`
- `- (void)setValue:(nullable id)value forKey:(NSString *)key;`

key 是没有任何限制的，如果知道某各类的私有变量名称是可以直接获取变量和设置变量的值
**会破坏面向对象编程思想的**

### Get 方法调用流程

![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/Objective-C/getresult.png)

Accessor Method
如果 `[obj valueForkey:@"key"]` 访问方法存在的规则
- `getKey`
- 有属性名称 key
- isKey 如果实现isKey 的get方法

Instance Var
- `_key`
- `_iskey`
- `iskey`
- `iskey`

### set 方法调用流程
![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/Objective-C/getprogress.png)

## 属性关键字

关键字分类
- 读写权限
    - readonly
    - readwrite
- 原子性
    - atomic
    - nonatomic
- 引用计数
    - retain/strong
    - assign/unsafe_unretained
    - week
    - copy

atomic 
- 修饰数组，赋值获取，可以保证线程安全
- 添加对象，移除对象，不能保证线程安全
assign 
- 修饰基本数据类型
- 修饰对象类型，不改变引用计数，
- 会产生悬垂指针，对象释放后悔指向原对象地址
week
- 不改变对象的引用计数
- 所指对象在释放后悔自动设置为`nil`
copy
- 可变对象copy后变成不可变对象
- 不可变对象copy后还是不可变对象

![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/Objective-C/copyresult.png)

assign和week区别
1 assgin 可以修改对象和基本数据类型，week 只能修饰对象
2 assgin 释放后指针指向原对象地址



