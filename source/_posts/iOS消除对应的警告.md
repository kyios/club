---
title: iOS消除对应的警告
date: 2018-01-12 21:17:31
tags:
  - tag
categories:
  - Git
author: 奎宇

---
# iOS消除对应的警告！


在iOS开发过程中, 我们可能会碰到一些系统方法弃用, weak、循环引用、不能执行之类的警告。 有代码洁癖的孩子们很想消除他们, 今天就让我们来一次Fuck 警告！！

首先学会基本的语句
`#pragma clang diagnostic push`
`#pragma clang diagnostic ignored "-Wdeprecated-declarations"`
这里写出现警告的代码
`#pragma clang diagnostic pop`
这样就消除了方法弃用的警告！
同理, 大家可以在下边搜索到对应的警告, 这样 就可以把前边的字串填入上边的ignored的后边, 然后阔住你的代码, 就OK了


<!--more-->
{% pdf https://kuiyu-1258489344.cos.ap-chengdu.myqcloud.com/iOS%E6%B6%88%E9%99%A4%E5%AF%B9%E5%BA%94%E7%9A%84%E8%AD%A6%E5%91%8A/warming.pdf %}
