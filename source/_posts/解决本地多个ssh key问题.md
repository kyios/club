title: Git 使用笔记
date: 2017-01-18 14:12:00
---

## 解决本地多个ssh key问题
有的时候，不仅github使用ssh key，工作项目或者其他云平台可能也需要使用ssh key来认证，如果每次都覆盖了原来的id_rsa文件，那么之前的认证就会失效。这个问题我们可以通过在~/.ssh目录下增加config文件来解决。

<!-- more -->

下面以配置git oschina的ssh key为例。

1. 生成ssh key时同时指定保存的文件名,这里也可以不用指定，只需要在创建的时候根据提示修改就可以，这里使用直接指定路径文件名的方式

ssh-keygen -t rsa -f ~/.ssh/oschina/id_rsa -C "email"
这时~/.ssh目录下会多出oschina/id_rsa和oschina/id_rsa.pub两个文件，id_rsa.pub里保存的就是我们要使用的key。

2. 新增并配置config文件

添加config文件

如果config文件不存在，先添加；存在则直接修改

touch ~/.ssh/config
在config文件里添加如下内容(User表示你的用户名)

Host git.oschina.net
    HostName git.oschina.net
    IdentityFile ~/.ssh/oschina/id_rsa
    User git
3. 上传key到oschina http://git.oschina.net/profile/sshkeys



4. 测试ssh key是否配置成功

ssh -T git@git.oschina.net
成功的话会显示：

Welcome to Git@OSC, 张大鹏!
至此，本地便成功配置多个ssh key。日后如需添加，则安装上述配置生成key，并修改config文件即可。





ssh-keygen -t rsa -C "注册的github邮箱"
终端执行命令：ssh-keygen -t rsa -C "注册的github邮箱"，这次一定要注意，对生成定的秘钥进行重命名，这里暂且重命名为id_rsa_home,同样不设置密码。可以看到生成的公私秘钥已经分别被重命名为id_rsa_home.pub和id_rsa_home。
检测

## 配置config
在.ssh/目录下新建config文件：touch config，通过nano编辑器进行如下配置：
```
Host git.365jiating.com
    HostName git.365jiating.com
    IdentityFile ~/.ssh/roobo/id_rsa
    User git
```
检测gitlab连接，如果提示是否建立连接，直接yes就行：


检测github连接：


不报错的话，就说明设置成功了！

## 步骤二：配置~/.ssh/config文件，以我自己的机器为例。

```
#Default Git
Host defaultgit
  HostName IP Address #域名也可
  User think
  IdentityFile ~/.ssh/id_rsa

#Second Git
Host secondgit
  HostName IP Address #域名也可
  User think
  IdentityFile ~/.ssh/id_rsa_second
```
## 步骤三：执行ssh-agent让ssh识别新的私钥。
```
ssh-add ~/.ssh/id_rsa_new
```
该命令如果报错：Could not open a connection to your authentication agent.无法连接到ssh agent，可执行ssh-agent bash命令后再执行ssh-add命令。


也可以修改提交的用户名和Email：
```
git commit --amend --author='Your Name '
```