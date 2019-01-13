---
title: IOS Block 总结
date: 2018-9-12 21:15:45
tags:
  - IOS
categories:
  - Block
author: 奎宇

---


# Block
> block 是c 的运行时代码块。类似c，但是在执行过程中，还可以动态绑定堆栈里面的数据。可以对变量使用和修改。
> c 语言不支持带有自动变量（局部变量）的匿名函数，block 是支持带有自动变量（局部变量）的匿名函数


 匿名函数:
 
```
int func(int count);

int (*funcPtr)(int) = &func;
int result = (*funcPtr)(10);

```

## block 引用外部变量
### block 捕获外部局部变量
```
int val = 10; 
void (^block)(void) = ^{
    printf("val=%d\n",val);
}; 
val = 2; 
block(); 
```
>上面这段代码，输出值是：val = 10，而不是2。

<!--more-->

```
int main(int argc, char * argv[]) {

    int val = 10;
    int va2l = 10;
    void (*blk)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, val, va2l));
    val = 2;
    ((void (*)(__block_impl *))((__block_impl *)blk)->FuncPtr)((__block_impl *)blk);
    return 1;
}
```

```
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  int val = __cself->val; // bound by copy

  printf("%d",val);
}
```

`int val = __cself->val; // bound by copy`
新建了对象后对值进行了拷贝,内部不能对外部的变量修改，不然编译报错: Variable is not assignable (missing `__block type specifier`)



### block 捕获外部全局变量
```
@implementation TestClass
- (instancetype)init
{
    self = [super init];
    if (self) {
        testVal = 88;
    }
    return self;
}

- (void)testfun{
    void (^blk)(void) = ^{
        NSLog(@"%d --> 1",testVal);
        testVal = 99;
        NSLog(@"%d --> 2",testVal);
    };
    testVal = 66;
    blk();
    NSLog(@"%d --> 1",testVal);

}

- (void)dealloc{
    NSLog(@"%@",@"dealloc");
}
@end

```
>上面这段代码，输出值是：66 --> 1 99 --> 2


```
static instancetype _I_TestClass_init(TestClass * self, SEL _cmd) {
    self = ((TestClass *(*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("TestClass"))}, sel_registerName("init"));
    if (self) {
        (*(int *)((char *)self + OBJC_IVAR_$_TestClass$testVal)) = 88;
    }
    return self;
}


static void __TestClass__testfun_block_func_0(struct __TestClass__testfun_block_impl_0 *__cself) {
  TestClass *self = __cself->self; // bound by copy

        NSLog((NSString *)&__NSConstantStringImpl__var_folders_gx_vvhdc9796yl0wh42wfmx849c0000gn_T_main_c00845_mii_0,(*(int *)((char *)self + OBJC_IVAR_$_TestClass$testVal)));
        (*(int *)((char *)self + OBJC_IVAR_$_TestClass$testVal)) = 99;
        NSLog((NSString *)&__NSConstantStringImpl__var_folders_gx_vvhdc9796yl0wh42wfmx849c0000gn_T_main_c00845_mii_1,(*(int *)((char *)self + OBJC_IVAR_$_TestClass$testVal)));
    }

static void _I_TestClass_testfun(TestClass * self, SEL _cmd) {
    void (*blk)(void) = ((void (*)())&__TestClass__testfun_block_impl_0((void *)__TestClass__testfun_block_func_0, &__TestClass__testfun_block_desc_0_DATA, self, 570425344));
    (*(int *)((char *)self + OBJC_IVAR_$_TestClass$testVal)) = 66;
    ((void (*)(__block_impl *))((__block_impl *)blk)->FuncPtr)((__block_impl *)blk);
}
```

> 在block 内部和外部修改变量值都是通过self 来修改。没有创建新的变量 


### block 捕获静态变量

```
static int testVal = 2;

@implementation TestClass
- (void)testfun{
    void (^blk)(void) = ^{
        testVal = 99;
        NSLog(@"%d --> 1",testVal);
    };
    blk();
}


@end
```
>上面这段代码，输出值是：99 --> 1



```
static void __TestClass__testfun_block_func_0(struct __TestClass__testfun_block_impl_0 *__cself) {
        testVal = 99;
        printf("%d",testVal);
}
```

>可以修改静态变量的值：静态变量属于类的，不是某一个变量。由于block内部不用调用self指针。所以block可以调用。

### 全局block 访问全局变量 -- 循环引用

```
@interface TestClass : NSObject{
}
@property(nonatomic,assign) int testVal;
@property(nonatomic,strong) void(^testBlock)();
- (void)testfun;
@end

@implementation TestClass
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.testVal = 99;
        [self setTestBlock:^{
            int tempValue = _testVal;
            printf("%d",tempValue) ;
        }] ;
        self.testVal = 88;
    }
    return self;
}
- (void)testfun{
    self.testBlock();
}
- (void)dealloc{
    NSLog(@"%@",@"dealloc");
}
@end
```
>上面这段代码，输出值是：88,没有执行 dealloc，循环引用

// code 1
```
static instancetype _I_TestClass_init(TestClass * self, SEL _cmd) {
    self = ((TestClass *(*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("TestClass"))}, sel_registerName("init"));
    if (self) {
        ((void (*)(id, SEL, int))(void *)objc_msgSend)((id)self, sel_registerName("setTestVal:"), 99);
        ((void (*)(id, SEL, void (*)()))(void *)objc_msgSend)((id)self, sel_registerName("setTestBlock:"), ((void (*)())&__TestClass__init_block_impl_0((void *)__TestClass__init_block_func_0, &__TestClass__init_block_desc_0_DATA, self, 570425344))) ;
        ((void (*)(id, SEL, int))(void *)objc_msgSend)((id)self, sel_registerName("setTestVal:"), 88);
    }
    return self;
}
```


```
// code 2
struct __TestClass__init_block_impl_0 {
  struct __block_impl impl;
  struct __TestClass__init_block_desc_0* Desc;
  TestClass *self;
  __TestClass__init_block_impl_0(void *fp, struct __TestClass__init_block_desc_0 *desc, TestClass *_self, int flags=0) : self(_self) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```


```
// code 3
static void __TestClass__init_block_func_0(struct __TestClass__init_block_impl_0 *__cself) {
    TestClass *self = __cself->self; // bound by copy
    int tempValue = (*(int *)((char *)self + OBJC_IVAR_$_TestClass$_testVal));
    printf("%d",tempValue) ;
}
```

> TestBlock 是全局变量，`__TestClass__init_block_impl_0` 对self 有引用（只要是全局变量都会使用self 来获取），self retainCount + 1，TestClass 释放的时候 retainCount -1 ,在释放 block 对象的时候，block 有self 的强指针，导致无法释放


## block 存放区域
#### 存放的是 NSConcreteStackBlock

```
- (void)testfun{
    int testVal = 10 ;

    void (^blk)(void) = ^{
        printf("%d",testVal);
    };
    testVal = 2;
    blk();
}
```

```
struct __TestClass__testfun_block_impl_0 {
  struct __block_impl impl;
  struct __TestClass__testfun_block_desc_0* Desc;
  int testVal;
  __TestClass__testfun_block_impl_0(void *fp, struct __TestClass__testfun_block_desc_0 *desc, int _testVal, int flags=0) : testVal(_testVal) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```


#### 存放的是 NSConcreteStackBlock

```
- (void)testfun{
    void (^blk)(void) = ^{
        int testVal = 10 ;
        printf("%d",testVal);
    };
    blk();
}
```

```
struct __TestClass__testfun_block_impl_0 {
  struct __block_impl impl;
  struct __TestClass__testfun_block_desc_0* Desc;
  __TestClass__testfun_block_impl_0(void *fp, struct __TestClass__testfun_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```


#### NSConcreteStackBlock

```
@interface TestClass : NSObject{
    int testVal ;
}
- (void)testfun;
@end

@implementation TestClass
- (instancetype)init
{
    self = [super init];
    if (self) {
        testVal = 10;
    }
    return self;
}

- (void)testfun{
    void (^blk)(void) = ^{
        printf("%d",self->testVal);
    };
//    testVal = 2;
    blk();
}

- (void)dealloc{}
@end

```

```
struct __TestClass__testfun_block_impl_0 {
  struct __block_impl impl;
  struct __TestClass__testfun_block_desc_0* Desc;
  TestClass *self;
  __TestClass__testfun_block_impl_0(void *fp, struct __TestClass__testfun_block_desc_0 *desc, TestClass *_self, int flags=0) : self(_self) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```

###  NSConcreteStackBlock

```
@interface TestClass : NSObject{
    int testVal ;
}
@property (nonatomic,strong) void (^testBlock)();
@end

@implementation TestClass
- (instancetype)init
{
    self = [super init];
    if (self) {
        testVal = 10;
        [self setTestBlock:^{
            
        }];
    }
    return self;
}
@end

struct __TestClass__init_block_impl_0 {
  struct __block_impl impl;
  struct __TestClass__init_block_desc_0* Desc;
  __TestClass__init_block_impl_0(void *fp, struct __TestClass__init_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```

### NSConcreteGlobalBlock

```

void (^blk) () = ^{
    printf("Block");
};
- (void)testfun{
    blk();
}

struct __blk_block_impl_0 {
  struct __block_impl impl;
  struct __blk_block_desc_0* Desc;
  __blk_block_impl_0(void *fp, struct __blk_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteGlobalBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

```



