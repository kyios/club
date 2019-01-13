---
title: 神奇的__attribute__
date: 2017-01-12 21:41:44
tags:
  - tag
categories:
  - Git
author: 奎宇

---
# 神奇的`__attribute__`

`__attribute__`是`GNU C`特色之一,在iOS用的比较广泛。如果你没有用过，那系统库你总用过，在Foundation.framework中有很多地方用到`__attribute__`特性。`__attribute__` 可以设置函数属性（`Function Attribute` ）、变量属性（`Variable Attribute` ）和类型属性（`Type Attribute `）。接下来就从iOS中常见用法谈起。
## format

作用：编译器会检查格式化字符串与“...”的匹配情况，防止产生难以发现的Bug。
`__attribute__((format(printf,m,n)))`
`__attribute__((format(scanf,m,n)))`
其中参数m与n的含义为：
m 格式化字符串（format string）的位置（顺序从1开始）；
n 参数“…”的位置（顺序从1开始）；
```
FOUNDATION_EXPORT  NSLog(NSString *format, ...) NS_FORMAT_FUNCTION;
#define NS_FORMAT_FUNCTION(F,A) __attribute__((format(__NSString__, F, A)))
#define kMaxStringLen 

extern  MyLog(const  *tag,const  *format,...) __attribute__((format(printf,,)));

 MyLog(const  *tag,const  *format,...) {
    va_list ap;
    va_start(ap, format);

    * pBuf = (*)malloc(kMaxStringLen);
     (pBuf != )
    {
        vsnprintf(pBuf, kMaxStringLen, format, ap);
    }
    va_end(ap);

    printf("TAG:%s Message:%s",tag,pBuf);

    (pBuf);
}
```
## deprecated

作用：使编译会给出过时的警告。
`__attribute__((deprecated))`
`__attribute__((deprecated(s)))`
```
#define DEPRECATED_ATTRIBUTE  __attribute__((deprecated))
#if __has_feature(attribute_deprecated_with_message)
  #define DEPRECATED_MSG_ATTRIBUTE  __attribute__((deprecated))
#else
  #define DEPRECATED_MSG_ATTRIBUTE  __attribute__((deprecated))
#endif
```
## availability

作用：指明API版本的变更。
`__attribute__((availability(macosx,introduced=m,deprecated=n)))`
m 引入的版本
n 过时的版本
```
#define CF_DEPRECATED_IOS(_iosIntro, _iosDep, ...) __attribute__((availability(,introduced=_iosIntro,deprecated=_iosDep,message= __VA_ARGS__)))
```
## unavailable

作用：告诉编译器该方法不可用，如果强行调用编译器会提示错误。比如某个类在构造的时候不想直接通过init来初始化，只能通过特定的初始化方法，就可以将init方法标记为`unavailable。`
`__attribute__((unavailable))`
`#define UNAVAILABLE_ATTRIBUTE __attribute__((unavailable))`

```
#define NS_UNAVAILABLE UNAVAILABLE_ATTRIBUTE
#import <Foundation/Foundation.h>

@interface Person : NSObject

@property(nonatomic,) NSString *name;

@property(nonatomic,assign) NSUInteger age;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithName:(NSString *)name age:(NSUInteger)age;

@end
```
![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/%E7%A5%9E%E5%A5%87%E7%9A%84__attribute__/inittest.png)         

## const

作用：用于带有数值类型参数的函数上。当重复调用带有数值参数的函数时，由于返回值是相同的，所以此时编译器可以进行优化处理，除第一次需要运算外， 其它只需要返回第一次的结果就可以了，进而可以提高效率。该属性主要适用于没有静态状态和副作用的一些函数，并且返回值仅仅依赖输入的参数。（const参数不能用在带有指针类型参数的函数中，因为该属性不但影响函数的参数值，同样也影响到了参数指向的数据，它可能会对代码本身产生严重甚至是不可恢复的严重后果。）
`__attribute__((const))`
```__attribute__((const)) add( x)
{
    printf("%s(%d)\n", __FUNCTION__, x);
    return x + ;
}

{
    printf("%s(%d)\n", __FUNCTION__, x);
    return x + ;
}

 ( argc, * argv[])
{
     i, j;

    i = add();
    j = add();

    printf("%d %d\n", i, j);

    i = add2();
    j = add2();

    printf("%d %d\n", i, j);

    return ;
}
```
## cleanup

作用：离开作用域之后执行指定的方法。实际应用中可以在作用域结束之后做一些特定的工作，比如清理。
用法 ：`__attribute__((cleanup(...)))`
```
static  stringCleanUp(__strong NSString **string) {
    NSLog(@, *string);
}

 testCleanUp {
    __strong NSString *string __attribute__((cleanup(stringCleanUp))) = @"stringCleanUp";
}

static  blockCleanUp(__strong (^ *block)) {
     (*block) {
        (*block)();
    }
}

 testBlockCleanUp {
    __strong (^block) __attribute__((cleanup(blockCleanUp))) = ^{
        NSLog(@"block");
    };
}

static  lambdaCleanUp( (**lambda)) {
     (*lambda) {
        (*lambda)();
    }
}

 testLambdaCleanUp {
     (*lambda)() __attribute__((cleanup(lambdaCleanUp))) = []() {
        ("lambda");
    };
}

 ( argc,  * argv[]) {
   @autoreleasepool {
      testCleanUp();

      testBlockCleanUp();

      testLambdaCleanUp();

   }
 return ;
}
//结合宏定义使用
#define BlockCleanUp __strong void(^block)() __attribute__((cleanup(blockCleanUp))) = ^
#define LambdaCleanUp void (*lambda)() __attribute__((cleanup(lambdaCleanUp))) = []()
 testDefine {
    BlockCleanUp {
        ("BlockCleanUp");
    };

    LambdaCleanUp{
        ("LambdaCleanUp");
    };
}
```
## constructor与destructor

作用：`__attribute__((constructor))` 在main函数之前执行,`__attribute__((destructor))` 在main函数之后执行。`__attribute__((constructor(PRIORITY)))`和`__attribute__((destructor(PRIORITY)))`按优先级执行。（可用于动态库注入的Hook）
用法：
`__attribute__((constructor)) `
`__attribute__((destructor))`
`__attribute__((constructor(PRIORITY)))`
`__attribute__((destructor(PRIORITY)))`
PRIORITY 为优先级
```
__attribute__((constructor))  start() {
    NSLog(@,__FUNCTION__);
}

 __attribute__((destructor)) end() {
     NSLog(@,__FUNCTION__);
}


void main( argc,  * argv[]) {

    NSLog(@,__FUNCTION__);

    return ;
}
```
![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/%E7%A5%9E%E5%A5%87%E7%9A%84__attribute__/printlog.png)
```
__attribute__((constructor)) start() {
    NSLog(@"%s",__FUNCTION__);
}

 __attribute__((constructor()))  start100() {
    NSLog(@"%s",__FUNCTION__);
}

 __attribute__((constructor()))  start101() {
    NSLog(@"%s",__FUNCTION__);
}

 __attribute__((destructor)) end() {
    NSLog(@"%s",__FUNCTION__);
}

 __attribute__((destructor)) end100() {
     NSLog(@"%s",__FUNCTION__);
}

 __attribute__((destructor)) end101() {
    NSLog(@"%s",__FUNCTION__);
}

 main( argc,  * argv[]) {

    NSLog(@"%s",__FUNCTION__);

    return ;
}
```        
![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/%E7%A5%9E%E5%A5%87%E7%9A%84__attribute__/printlog2.png)

## noreturn

作用：定义有返回值的函数时，而实际情况有可能没有返回值，此时编译器会报错。加上attribute((noreturn))则可以很好的处理类似这种问题。
用法：
`__attribute__((noreturn))`
 `__attribute__((noreturn)) onExit();`

``` ( state) {
     (state == ) {
        onExit();
    } {
        return ;
    }
}
```
## nonnull

作用：编译器对函数参数进行NULL的检查
用法：`__attribute__((nonnull(...)))`
```
extern  *my_memcpy_2 ( *dest, const  *src, size_t len) __attribute__((nonnull (, )));

extern  *my_memcpy_3 ( *dest, const  *src, const  *other, size_t len) __attribute__((nonnull (, , )));

 test_my_memcpy {
    my_memcpy_2(, , );
    my_memcpy_3(, , , );
}
```  
![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/%E7%A5%9E%E5%A5%87%E7%9A%84__attribute__/my_memcpy2.png)

## aligned 与 packed

作用：`aligned(m)` 将强制编译器尽其所能地确保变量在分配空间时采用m字节对齐方式。`packed`该属性对`struct` 或者`union` 类型进行定义，设定其类型的每一个变量的内存约束，当用在`enum` 类型定义时，暗示了应该使用最小完整的类型。`aligned` 属性使被设置的对象占用更多的空间，使用`packed` 可以减小对象占用的空间。
用法： `attribute ((aligned (m)))`
`attribute ((aligned))`
`attribute ((packed))`
```
//运行在iPhone5模拟器上
struct p {
     a;
     b;
    short c;
}__attribute__((aligned())) pp;

struct m {
     a;
     b;
    short c;
}__attribute__((aligned())) mm;

struct o {
     a;
     b;
    short c;
}oo;

struct x {
     a;
     b;
    struct p px;
    short c;
 }__attribute__((aligned())) xx;

struct MyStruct {
     c;
      i;
    short s;
}__attribute__ ((__packed__));

struct MyStruct1 {
     c;
      i;
    short s;
}__attribute__ ((aligned));

struct MyStruct2 {
     c;
      i;
    short s;
}__attribute__ ((aligned()));

struct MyStruct3 {
     c;
      i;
    short s;
}__attribute__ ((aligned()));

struct MyStruct4 {
     c;
      i;
    short s;
}__attribute__ ((aligned()));

 ( argc,  * argv[]) {

    printf("sizeof(int)=%lu,sizeof(short)=%lu.sizeof(char)=%lu\n",sizeof(),sizeof(short),sizeof());

    printf("pp=%lu,mm=%lu \n", sizeof(pp),sizeof(mm));

    printf("oo=%lu,xx=%lu \n", sizeof(oo),sizeof(xx));

    printf("mystruct=%lu \n", sizeof(struct MyStruct));

    printf("mystruct1=%lu \n", sizeof(struct MyStruct1));

    printf("mystruct2=%lu \n", sizeof(struct MyStruct2));

    printf("mystruct3=%lu \n", sizeof(struct MyStruct3));

    printf("mystruct4=%lu \n", sizeof(struct MyStruct4));

    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
```       
![](https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/%E7%A5%9E%E5%A5%87%E7%9A%84__attribute__/printlog3.png)
参考资料：
http://nshipster.com/__attribute__/