---
title: RunTime 相关结构体
date: 2018-11-13 18:21:29
tags:
  - IOS
categories:
  - Runtime
author: 奎宇

---

# RunTime 相关结构体

**Runtime 功能介绍**

![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/RunTime-%E7%9B%B8%E5%85%B3%E7%BB%93%E6%9E%84%E4%BD%93/runtime_map.png)


## `objc_object`
![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/RunTime-%E7%9B%B8%E5%85%B3%E7%BB%93%E6%9E%84%E4%BD%93/objc_object_map.png)

## `objc_class`

![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/RunTime-%E7%9B%B8%E5%85%B3%E7%BB%93%E6%9E%84%E4%BD%93/objc_class_map.png)

`Class` 描述
- `objc_class` 的结构体
- 类对象(继承自`objc_object`)

`superClass` 指向`Class`,如果类对象指向父类。
`cache` 代表方法缓存。
`bits` 包含该类变量、属性、方法

## `isa_t`

> C++ 中的共用体,在32（64）位是32（64）个 0 或者1数字

![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/RunTime-%E7%9B%B8%E5%85%B3%E7%BB%93%E6%9E%84%E4%BD%93/isa_ma.png)

分成指针型和非指针型的目的是，实际只有30-40位就可以寻找到 `class`地址，多出来的部分其他的内容，达到节省内存的目的

**指向**

- **对象**，指向 **类对象**
- **类对象**，指向 **元类对象（MetaClass）**

> 方法查找： 
> 对象的方法通过对象所对应的类对象进行方法查找
> 类对象方法通过所对应元类对象进行方法查找

## `cache_t`
**用于快速查找方法执行函数**提高方法调用的速度，和传递的书读
**是可以增量扩展的哈希表结构**
**是局部性原理最佳应用**

局部性原理：把调用率方法放入缓存中，下次调用的命中率会高一些

```
struct cache_t {
    struct bucket_t *_buckets;
    mask_t _mask;
    mask_t _occupied;
 }
```

```
struct bucket_t {
private:
    cache_key_t _key;
    IMP _imp;
};
```

## `class_data_bits_t`

- `class_data_bits_t` 主要对 `class_rw_t`的封装
- `class_rw_t`代表了类相关的**读写**信息、对`class_ro_t`的封装
- `class_ro_t` 代表了类的**只读**信息
### `class_rw_t`
![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/RunTime-%E7%9B%B8%E5%85%B3%E7%BB%93%E6%9E%84%E4%BD%93/class_rw_t.png)
`class_rw_t` 包含类及其分类中的协议、属性、方法

### `class_ro_t`
![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/RunTime-%E7%9B%B8%E5%85%B3%E7%BB%93%E6%9E%84%E4%BD%93/class_ro_t.png)

- `name` 类名
- `ivars` 声明或定义的类的成员变量
- `properties` 类的属性
- `protocols` 写的遵从的协议
- `methodList` 方法列表

`class_ro_t` 包含该类中的协议、属性、方法。

### `method_t`
![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/RunTime-%E7%9B%B8%E5%85%B3%E7%BB%93%E6%9E%84%E4%BD%93/method_t.png)
```
struct method_t {
    SEL name;
    const char *types;
    IMP imp;
};
```

- `name` 方法名称
- `types` 方法的返回值和参数的组合
- `imp` 无类型的函数指针，指向的是函数体

#### Type Encodings `method_t`->`types` 
![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/RunTime-%E7%9B%B8%E5%85%B3%E7%BB%93%E6%9E%84%E4%BD%93/type%20Encodings.png)

![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/RunTime-%E7%9B%B8%E5%85%B3%E7%BB%93%E6%9E%84%E4%BD%93/testmethod.png)

![](/RunTime-相关结构体/20190113085645545.png)

![](/RunTime-相关结构体/20190113085628224.png)


