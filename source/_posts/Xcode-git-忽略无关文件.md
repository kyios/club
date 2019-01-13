title: Xcode git 忽略无关文件
author: Kieran zhi
tags:
  - Xcode
  - IOS
categories:
  - Git
date: 2017-06-22 17:37:00
---
 Git**版本控制**的时候，有很多非代码文件也会被跟踪，比较常见的如一些影藏文件DS_Store、以xcworkspace、xcuserstate、xcuserdata等结尾的状态文件等。为了不把这些文件加入版本控制体系中，我们需要进行以下三步设置，注意，每一步必不可少，也不可交换位置，下文会具体解释原因。 



1. 第一步：进入git的代码仓库，执行以下的代码
    
```
git rm --cached *.xcuserstate
git rm --cached *.xcuserdata
```
> 这两行代码（或者可以有更多，自己修改后缀名即可，这里列出了常见的两种隐藏文件）表示不再追踪以这些后缀结尾的文件，注意这里的文件在执行代码前其实已经被追踪（Tracked），执行完后，将不再被追踪。

2. 修改.gitignore文件

```
vim .gitignore
```
> 这时候会进入gitignore的文件的编辑界面，如果这个文件已经存在，则可以通过普通的文本编辑器直接进行修改（需要设置显示隐藏文件），复制以下内容进入.gitignore文件。（ignore.io推荐）

```
build/
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
xcuserdata
*.xccheckout
*.moved-aside
DerivedData
*.xcuserstate
```

> 按esc键退出编辑，输入：wq保存文件。 
> 注意这里的gitignore文件的修改，仅对未追踪（Untracked）的文件生效，所以首先要执行第一步，取消对以上类型文件的追踪。
> 

3. 第三步：提交此处版本修改
```
git add .
git commit -m "igonre files "
git push origin master
```

**重启Xcode并且尝试修改一个文件后执行commit，发现那些与代码无关的文件并不会被自动提交了**
