title: cocoapod 笔记
tags:
  - 开发
categories:
  - IOS
date: 2017-01-18 14:12:00
---

### 设置gem为最新版本

```
sudo gem update --system
```


### pod 安装
```
$ gem update --system # 这里请翻墙一下

$ gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/

$ gem sources -l

# https://gems.ruby-china.org

$ sudo gem install cocoapods

 sudo gem install -n /usr/local/bin cocoapods
解决无安装权限



$ pod setup

cd ~/.cocoapods

du -sh *
```

<!-- more -->

###  cocoapod 私有库创建

```
pod lib create RBBusKit
```
```
pod lib lint
```


```
pod trunk push //提交公有
pod trunk push --allow-warnings
```

----

###  cocoapod 私有库

```
#podfile 文件路径
pod repo add RBVideoSDK  https://git.365jiating.com/zhikuiyu/RBVideoKit.git

```

```
pod repo push RBVideoSDK RBVideoSDK.podspec
```


```
pod lib lint --sources=git@git.365jiating.com:zhikuiyu/videoSpec.git,master --no-clean --verbose --allow-warnings
```




### 搜索不到内容

```
rm ~/Library/Caches/CocoaPods/search_index.json   
```

### pod 注册
```
pod trunk register zhikuiyu@roo.bo 'zhikuiyu' --description='zhikuiyu'

pod trunk register zky_416@sina.com 'zhikuiyu' --description='zhikuiyu'
```


### pod 
```
- ERROR | [iOS] unknown: Encountered an unknown error (757: unexpected token a

launchctl remove com.apple.CoreSimulator.CoreSimulatorService
killall -9 com.apple.CoreSimulator.CoreSimulatorService
```