title: Git 使用笔记
tags:
  - Git
categories:
  - 开发
date: 2017-01-18 14:12:00
---

# 项目组件目录

---

#### 数据基类

```
  pod 'RBBusKit', :git => 'git@git.365jiating.com:zhikuiyu/Pudding_RBBusKit.git'


```

#### git 代码合并

```
git pull origin master

```

#### 提交到git 服务器

```
git push origin master

```

#### git 代码回退

```
git reset commtiversion filename ##回退部分代码
git reset ## 全部 回退
git reset HEAD^

```

#### git tag


```
git tag 1.1.0
git push --tags
git push origin tag 1.1.1

//第一种删除tag
git tag -d 1.1.1 //删除tag
git push origin :refs/tags/1.1.1 //提交删除

//第二种删除tag
git push origin --delete tag 1.1.1
```




#### git 创建仓库

```
echo "# ZYSource" >> README.md
git init
git add README.md
git commit -m "first commit"
git remote add origin git@github.com:zhiyu330691038/ZYSource.git
git push -u origin master


```
#### git  仓库清理

```
git rm

```

----


### git 子模块
```
#添加子模块
git submodule add git@git.365jiating.com:zhikuiyu/RBVideoKit.git

```
### git 切换分支
```
git checkout pudding
```
### git 提交切换分支
```
git checkout pudding
```

### git 切换仓库

```
 git remote rm origin
 git remote add origin https://git.oschina.net/rooboVideo/PuddingVideoSDK.git
```

### 查看远程仓库地址

```
git remote -v
```

### 添加远程仓库

```
git remote add origin git@git.365jiating.com:zhikuiyu/RBAlterView.git
```
