---
title: ios Runtime 总结
date: 2019-01-12 20:49:54
tags:
  - IOS
categories:
  - Runtime
author: 奎宇

---


> Runtime: 是基于c的api,是iOS内部的核心之一,底层都是基于它来实现的,oc是一门动态语言,在编译后好多类和对象是编译器不知道的,这时候需要运行时系统(runtime-system)来处理编译后的代码.


[TOC]
### Runtime消息传递

#### 方法调用
在OC中方法都是通过Runtime实现的。下面效果是相同的
```
TestClass * test  = [[TestClass alloc] init];
//----------------------------------------
[test testfun];
((SEL (*)(id, SEL))(void *)objc_msgSend)((id)test, @selector(testfun));
//----------------------------------------
//方法带参数
[test testfunArg1:333 Arg2:@"abcd"];
((void (*)(id, SEL, long double , NSString *))(void *) objc_msgSend)((id)test, @selector(testfunArg1:Arg2:), 333 ,@"abcd");
```


```
//类方法调用
objc_msgSend(objc_getClass("TestClass"), sel_registerName("alloc"));
```
**项目中不同的类声明不同的方法，SEL 是同一个**

```
TestClass * test  = [[TestClass alloc] init];
[test testfun];
    
TestClass2 * test2  = [[TestClass2 alloc] init];
[test2 testfun];

//打印结果
TestObject testMethod 0x1097799f2
TestObject testMethod 0x1097799f2
```
> Runtime 中维护了一个`SEL`的表。这个表不按类来存储。只要`SEL`相同就当做同一个，存储到表中。项目加载的时候所有的方法都会加载到这个表中，动态生成的方法也就加载到表中。

```
static struct /*_method_list_t*/ {
	unsigned int entsize;  // sizeof(struct _objc_method)
	unsigned int method_count;
	struct _objc_method method_list[3];
}
```
<!--more-->
#### 隐藏参数

常用的2个隐藏参数 `self` `_cmd`

```
@interface TestClass : NSObject{
    int testVal ;
}
@end
//oc 类
@implementation TestClass
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)testfun:(NSString *)string{
}

void testCfun(int abc){
//如果调用类里面函数的全局变量
    testVal = 10; //build error Use of undeclared identifier 'testVal'
}
@end
```


```
转换后
static instancetype _I_TestClass_init(TestClass * self, SEL _cmd) {
    self = ((TestClass *(*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("TestClass"))}, sel_registerName("init"));
    if (self) {
    }
    return self;
}

static void _I_TestClass_testfun_(TestClass * self, SEL _cmd, NSString *__strong string) {
}

void testCfun(int abc){

}
```


```
[[TestClass alloc] init];
//会转换成

TestClass * test = ((TestClass *(*)(id, SEL))(void *)objc_msgSend)((id)((TestClass *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("TestClass"), sel_registerName("alloc")), sel_registerName("init"));
/**
*  相当于
*  id test = objc_msgSend(objc_getClass("TestClass"),sel_registerName("alloc"));
*  objc_msgSend(test, sel_registerName("init"));
*/
```


**Tips**


我们可以通过下面三种方法来获取SEL:

1. sel_registerName函数
2. Objective-C编译器提供的@selector()
3. NSSelectorFromString()方法

> 得到结论：oc 经过转换后，每个oc 的方法都会带有target，SEL，和参数。
> 方法 调动的时候 会携带 target 和方法参数等。target 就是`self`，方法名就是`_cmd`
> 由于C方法没有携带target，所以无法使用类的全局变量



```
@implementation TestClass
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}
- (void)testfun:(NSString *)string{
    printf("%s\n", [[[self class] description] UTF8String]);
    printf("%s\n" ,[[[super class] description] UTF8String]);
    printf("%s\n" ,[[[self superclass] description]UTF8String]);
    printf("%s\n" ,[[[TestClass superclass] description]UTF8String]);
}

@end

//打印结果
TestClass
TestClass
NSObject
NSObject
```
执行的源码


```
Class a1 = ((Class (*)(id, SEL))(void *)objc_msgSend)((id)self, sel_registerName("class"));

Class a2 = ((Class (*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("TestClass"))}, sel_registerName("class"));
    
Class a3 = ((Class (*)(id, SEL))(void *)objc_msgSend)((id)self, sel_registerName("superclass"));
    
Class a4 = ((Class (*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("TestClass"), sel_registerName("superclass"));
```

**第二行为什么不是NSObject**

**`objc_msgSendSuper`**

`id objc_msgSendSuper(struct objc_super *super, SEL op, …)`
 
* super 获取是传入实例和父类的class。生成的结构体如下

```
struct objc_super { 
   id receiver; 
   Class superClass; 
};
```
* SEL 要执行的方法

比如第二次获取。要执行`SEL`

> `objc_msgSendSuper` 执行 `class` 方法。是从 `objc_super->superClass` 的方法列表开始找`SEL`，然后 objc_super-> receiver 来执行这个方法。
> 由此可知 `super` 不管执行什么`objc_super->superClass` 都是 `self`
> 但是 `objc_super` 在执行方法过程中 `superClass` 搜索方法列表是从 `objc_super->superClass` 开始的。
> 比如 `self` `super` 都包含 `- (void)testfun:(NSString *)string`。方法直接执行父类的方法

**结论:super实际作用就是self 来执行父类的方法。如果父类没有，子类有相应的方法，程序直接回报错**


#### 方法执行（消息发送流程）

当对象创建的时候，完成初始化的时候，对象的第一个变量的指针`*isa`,`*isa`可以访问类的对象，并且可以通过对象来访问既继承链中的类。

当执行方法过程中，消息随着对象的`*isa`指针到类的结构体中，在method list 查找方法，找不到就沿着继承一直上找，知道NSObject。

`objc_msgsend` 发送消息过程中，同一个方法第一次是没有缓存的，使用后就会缓存。之后直接调用缓存。

查找方法首先从缓存里面查找。不会立即查看`methodLists`,优先查找缓存。


```
struct objc_class {
    Class _Nonnull isa  ;
    Class _Nullable super_class;
    const char * _Nonnull name;
    long version;
    long info;
    long instance_size;
    struct objc_ivar_list * _Nullable ivars;
    struct objc_method_list * _Nullable * _Nullable methodLists;
    struct objc_cache * _Nonnull cache;
    struct objc_protocol_list * _Nullable protocols;
} OBJC2_UNAVAILABLE;
```

```
struct objc_cache {
    unsigned int mask /* total = mask + 1 */                 OBJC2_UNAVAILABLE;
    unsigned int occupied                                    OBJC2_UNAVAILABLE;
    Method _Nullable buckets[1]                              OBJC2_UNAVAILABLE;
};

typedef struct method_t *Method;

struct method_t {
    SEL name;
    const char *types;
    IMP imp;
};
```
**`objc_msgSend_c` 执行前判断**

```
id objc_msgSend_c(id obj, SEL sel,...) {
    id localObj = obj;
    int64_t obj_i = (int64_t)obj;
    //这一部分处理tagged pointer的isa指针
    if (obj_i == 0) return nil;
    if (obj_i < 0) {
        //tagged pointer
        uintptr_t obj_ui = (uintptr_t)obj_i;
        if (obj_ui >= _OBJC_TAG_EXT_MASK) {
            uint16_t index = (obj_ui << _OBJC_TAG_PAYLOAD_LSHIFT) >> (_OBJC_TAG_EXT_INDEX_SHIFT + _OBJC_TAG_PAYLOAD_LSHIFT);
            localObj = objc_tag_ext_classes[index];
        } else {
            uint16_t index = obj_ui >> _OBJC_TAG_INDEX_SHIFT;
            localObj = objc_tag_classes[index];
        }
    }
    
}

```
**`lookUpImpOrForward` 负责查找`IMP`和转发代码**

```
IMP lookUpImpOrForward(Class cls, SEL sel, id inst, 
                       bool initialize, bool cache, bool resolver)
{
    IMP imp = nil;
    bool triedResolver = NO;

    runtimeLock.assertUnlocked();

    //  缓存中加载IMP，
    if (cache) {
        imp = cache_getImp(cls, sel);
        if (imp) return imp;
    }
    runtimeLock.read();
    //判断类是否被创建，如果没有被创建，实例化
    if (!cls->isRealized()) {
        runtimeLock.unlockRead();
        runtimeLock.write();
        realizeClass(cls);
        runtimeLock.unlockWrite();
        runtimeLock.read();
    }
    
    if (initialize  &&  !cls->isInitialized()) {
        runtimeLock.unlockRead();
        _class_initialize (_class_getNonMetaClass(cls, inst));
        runtimeLock.read();
    }

 retry:    
    runtimeLock.assertReading();
    // Try this class's cache.尝试获取这个类的缓存
    imp = cache_getImp(cls, sel);
    if (imp) goto done;

    // TrP this class's method lists.没有获取到缓存
    {
        //方法列表中获取对应的Method，加入缓存获取IMP
        Method meth = getMethodNoSuper_nolock(cls, sel);
        if (meth) {
            log_and_fill_cache(cls, meth->imp, sel, inst, cls);
            imp = meth->imp;
            goto done;
        }
    }

    // Try superclass caches and method lists.尝试父类缓存和方法列表中获取
    {
        unsigned attempts = unreasonableClassCount();
        for (Class curClass = cls->superclass;
             curClass != nil;
             curClass = curClass->superclass)
        {
            // Halt if there is a cycle in the superclass chain.
            if (--attempts == 0) {
                _objc_fatal("Memory corruption in class list.");
            }
            
            // Superclass cache.
            imp = cache_getImp(curClass, sel);
            if (imp) {
                if (imp != (IMP)_objc_msgForward_impcache) {
                    // Found the method in a superclass. Cache it in this class.
                    log_and_fill_cache(cls, imp, sel, inst, curClass);
                    goto done;
                }
                else {
                    // Found a forward:: entry in a superclass.
                    // Stop searching, but don't cache yet; call method 
                    // resolver for this class first.
                    break;
                }
            }
            
            // Superclass method list.
            Method meth = getMethodNoSuper_nolock(curClass, sel);
            if (meth) {
                log_and_fill_cache(cls, meth->imp, sel, inst, curClass);
                imp = meth->imp;
                goto done;
            }
        }
    }

    // No implementation found. Try method resolver once.
    // 消息转发模式，没有查到可执行的IMP，尝试动态解析
    if (resolver  &&  !triedResolver) {
        runtimeLock.unlockRead();
        _class_resolveMethod(cls, sel, inst);
        runtimeLock.read();
        // Don't cache the result; we don't hold the lock so it may have 
        // changed already. Re-do the search from scratch instead.
        triedResolver = YES;
        goto retry;
    }

    // No implementation found, and method resolver didn't help. 
    // Use forwarding.
    // 如果IMP没有找到，动态解析也没有处理，进入消息转发阶段
    imp = (IMP)_objc_msgForward_impcache;
    cache_fill(cls, sel, imp, inst);

 done:
    runtimeLock.unlockRead();
    return imp;
}
```
**_class_resolveMethod**
```
/***********************************************************************
* _class_resolveMethod
* Call +resolveClassMethod or +resolveInstanceMethod.
* Returns nothing; any result would be potentially out-of-date already.
* Does not check if the method already exists.
**********************************************************************/
void _class_resolveMethod(Class cls, SEL sel, id inst)
{
    if (! cls->isMetaClass()) {
        // try [cls resolveInstanceMethod:sel]
        _class_resolveInstanceMethod(cls, sel, inst);
    } 
    else {
        // try [nonMetaClass resolveClassMethod:sel]
        // and [cls resolveInstanceMethod:sel]
        _class_resolveClassMethod(cls, sel, inst);
        if (!lookUpImpOrNil(cls, sel, inst, 
                            NO/*initialize*/, YES/*cache*/, NO/*resolver*/)) 
        {
            _class_resolveInstanceMethod(cls, sel, inst);
        }
    }
}
```
**_class_resolveInstanceMethod**
```
static void _class_resolveInstanceMethod(Class cls, SEL sel, id inst)
{
    if (! lookUpImpOrNil(cls->ISA(), SEL_resolveInstanceMethod, cls, 
                         NO/*initialize*/, YES/*cache*/, NO/*resolver*/)) 
    {
        // Resolver not implemented.
        return;
    }

    BOOL (*msg)(Class, SEL, SEL) = (typeof(msg))objc_msgSend;
    bool resolved = msg(cls, SEL_resolveInstanceMethod, sel);

    // Cache the result (good or bad) so the resolver doesn't fire next time.
    // +resolveInstanceMethod adds to self a.k.a. cls
    IMP imp = lookUpImpOrNil(cls, sel, inst, 
                             NO/*initialize*/, YES/*cache*/, NO/*resolver*/);

    if (resolved  &&  PrintResolving) {
        if (imp) {
            _objc_inform("RESOLVE: method %c[%s %s] "
                         "dynamically resolved to %p", 
                         cls->isMetaClass() ? '+' : '-', 
                         cls->nameForLogging(), sel_getName(sel), imp);
        }
        else {
            // Method resolver didn't add anything?
            _objc_inform("RESOLVE: +[%s resolveInstanceMethod:%s] returned YES"
                         ", but no new implementation of %c[%s %s] was found",
                         cls->nameForLogging(), sel_getName(sel), 
                         cls->isMetaClass() ? '+' : '-', 
                         cls->nameForLogging(), sel_getName(sel));
        }
    }
}
```

```
/***********************************************************************
* lookUpImpOrNil.
* Like lookUpImpOrForward, but returns nil instead of _objc_msgForward_impcache
**********************************************************************/
IMP lookUpImpOrNil(Class cls, SEL sel, id inst, 
                   bool initialize, bool cache, bool resolver)
{
    IMP imp = lookUpImpOrForward(cls, sel, inst, initialize, cache, resolver);
    if (imp == _objc_msgForward_impcache) return nil;
    else return imp;
}

```

**总结:调用objc_msgSend后，逻辑判断**

1. 接收对象为`nil`,消息无效 (`objc_msgSend_c`)
2. 通过对象类的方法缓存里面查找（`cache_getImp`），如果有缓存直接返回IMP
3. 查找类的method list,查找有对应的SEL 对象，有的话获取Method 对象，获取Method 的IMP。并加入缓存。
4. 如果没有查找到，查询父类 ，重复 3，直至 `NSObject`
5. 如果始终获取不到。进入动态解析。`_class_resolveMethod` ，会检测如果是类方法 `_class_resolveClassMethod`,成员方法 `_class_resolveInstanceMethod`,进入动态解析。
6. 如果IMP没有找到，动态解析也没有处理，进入消息转发阶段。如果不错处理，就会crash

**下图是实际工作中的消息转发。**

![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/ios-Runtime-%E6%80%BB%E7%BB%93/messagere.png)


### 加载过程

IOS 动态库都是动态加载的。程序开始的时候才会链接动态库

#### APP 启动加载
1. 系统先读取App 的可执行文件，里面获取`dyld`路径。
2. `dyld`初始化运行环境，开启缓存策略，加载相关依赖库和可执行文件，依赖库的初始化。
3. `dyld`将可执行文件以及相应的依赖库与插入库加载进内存生成对应的ImageLoader类的image(镜像文件)对象，对这些image进行链接，调用各image的初始化方法等(递归调用)
3. 等待全部初始后，`Runtime`也初始化完成，会收到调用相关的回调。
4. `Runtime`对类进行类结构初始化。让后调用`+load`
5. 执行`main`

**`dyld`**

通过Mach-O文件查看器[MachOView](http://sourceforge.net/projects/machoview/)查看一个项目可执行文件

![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/ios-Runtime-%E6%80%BB%E7%BB%93/machover.png)

程序需要的dyld的路径在LC_LOAD_DY_LINKER命令里，一般都是在/usr/lib/dyld 路径下。这里的LC_MAIN指的是程序main函数加载地址，下面还有写LC_LOAD_DYLIB指向的都是程序依赖库加载信息，如果我们程序里使用到了AFNetworking，这里就会多一条名为LC_LOAD_DYLIB(AFNetworking)的命令

![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/ios-Runtime-%E6%80%BB%E7%BB%93/stafdsa.png)

**`Runtime`对类进行类结构初始化**

* `Runtime`实例化 `_objc_init` 调用
*  调用`_dyld_objc_notify_register`开始实例化
*  调用`load_images` 加载镜像
*  `load_images` 里面调用 `call_load_methods`
*  `call_load_methods` 调用 `call_class_loads`
*  开始调用 class 和 category 的`+load`方法
*  第一次属于类的方法调用 调用 `initialize`,如果不调用永远不会调用

```
static void schedule_class_load(Class cls)
{
    if (!cls) return;
    assert(cls->isRealized());  // _read_images should realize

    if (cls->data()->flags & RW_LOADED) return;

    // Ensure superclass-first ordering
    schedule_class_load(cls->superclass);

    add_class_to_loadable_list(cls);
    cls->setInfo(RW_LOADED); 
}
```
> `+load` 是在初始化时候调用，`main` 所有实例化后才会调用。类的方法`+load` 遍历所有的子类都加入。父类的在前。`category` 直接添加


### Category

> 在Category添加属性后，默认是没有实现方法的。当时编译不会错。调用会崩溃。

```

Property 'object' requires method 'object' to be defined - use @dynamic or provide a method implementation in this category
```

下面是保存属性的方法
```
void _object_set_associative_reference(id object, void *key, id value, uintptr_t policy) {
    // retain the new value (if any) outside the lock.
    ObjcAssociation old_association(0, nil);
    id new_value = value ? acquireValue(value, policy) : nil;
    {
        AssociationsManager manager;
        AssociationsHashMap &associations(manager.associations());
        disguised_ptr_t disguised_object = DISGUISE(object);
        if (new_value) {
            // break any existing association.
            AssociationsHashMap::iterator i = associations.find(disguised_object);
            if (i != associations.end()) {
                // secondary table exists
                ObjectAssociationMap *refs = i->second;
                ObjectAssociationMap::iterator j = refs->find(key);
                if (j != refs->end()) {
                    old_association = j->second;
                    j->second = ObjcAssociation(policy, new_value);
                } else {
                    (*refs)[key] = ObjcAssociation(policy, new_value);
                }
            } else {
                // create the new association (first time).
                ObjectAssociationMap *refs = new ObjectAssociationMap;
                associations[disguised_object] = refs;
                (*refs)[key] = ObjcAssociation(policy, new_value);
                object->setHasAssociatedObjects();
            }
        } else {
            // setting the association to nil breaks the association.
            AssociationsHashMap::iterator i = associations.find(disguised_object);
            if (i !=  associations.end()) {
                ObjectAssociationMap *refs = i->second;
                ObjectAssociationMap::iterator j = refs->find(key);
                if (j != refs->end()) {
                    old_association = j->second;
                    refs->erase(j);
                }
            }
        }
    }
    // release the old value (outside of the lock).
    if (old_association.hasValue()) ReleaseValue()(old_association);
}
```

对象都存入 `AssociationsHashMap`中


### Runtime 应用

#### 指令的应用

* `__attribute__` [用法](https://clang.llvm.org/docs/AttributeReference.html) 允许增加参数，做一些高级检查和优化


1.  `objc_subclassing_restricted` 不能被继承
```
__attribute__((objc_subclassing_restricted)) 
@interface TestObject : NSObject
@end
```
2.  `objc_requires_super` 子类必须实现父类的方法，否则警告
            
```
- (void)testMethod __attribute__((objc_requires_super)); 
```

3. `constructor / destructor` `main`函数前后执行,`__attribute__((constructor(101)))` 添加优先级

```
__attribute__((constructor)) static void beforeMain() { NSLog(@"before main");
}
__attribute__((destructor)) static void afterMain() { NSLog(@"after main");
}
```
4. `overloadable` 可重复方法名
    
```
__attribute__((overloadable)) void testMethod(int age) {} 
__attribute__((overloadable)) void testMethod(NSString *name) {} 
__attribute__((overloadable)) void testMethod(BOOL gender) {}
```

5. `cleanup` 释放变量前执行

```
TestObject *object __attribute__((cleanup(releaseBefore))) = [[TestObject alloc] init];
static void releaseBefore(NSObject **object) { 
    NSLog(@"%@", *object);
}

```


### ORM

对象的映射关系
