# 免密设置

## 第一步 生成密钥对
查看你的用户目录下是否有 `.ssh` 目录，如果有再看下是否存在 `rsa` 密钥对文件。
如果有跳过这一步，直接进入下一步。

```shell
ssh-keygen -t rsa -b 2048[/4096] -C "<comment>"

```
按回车
```
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/user/.ssh/id_rsa):
```
设置口令：
```
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
```
![](http://imgchr.lingwenlong.com/notes/img/Image.png)

## 第二步 添加 ssh 密钥

 ![](http://imgchr.lingwenlong.com/notes/img/20210531094026.png)

 ![](http://imgchr.lingwenlong.com/notes/img/20210531094103.png)

![](http://imgchr.lingwenlong.com/notes/img/20210531094147.png)

把上面生成的密钥对的公钥填入输入框
![](http://imgchr.lingwenlong.com/notes/img/20210531094241.png)

![](http://imgchr.lingwenlong.com/notes/img/20210531094329.png)
添加标题后，点击添加密钥

![](http://imgchr.lingwenlong.com/notes/img/20210531094438.png)
添加成功


# 使用
## 控制台操作

首先： 自己电脑上需要安装 `git`
[Git - Downloading Package (git-scm.com)](https://git-scm.com/download/win)
安装完成后,电脑会多出 `git` 控制台工具。
![](http://imgchr.lingwenlong.com/notes/img/20210531092005.png)
另外，也可以在控制台输入 `git`，会输出下面信息
![](http://imgchr.lingwenlong.com/notes/img/20210531092154.png)

下面进入主题：如何管理自己的代码文档等
选择你参与的项目
![](http://imgchr.lingwenlong.com/notes/img/20210531092342.png)

### 克隆项目
点击 `克隆`
![](http://imgchr.lingwenlong.com/notes/img/20210531092444.png)
使用 SSH 克隆，点后面的复制链接：
然后到你的工作目录,打开控制台：
![](http://imgchr.lingwenlong.com/notes/img/20210531094829.png)
结果：
![](http://imgchr.lingwenlong.com/notes/img/20210531094859.png)
到你的工作目录查看：
![](http://imgchr.lingwenlong.com/notes/img/20210531094930.png)

### 添加文件和提交
下面我们添加一个文件
![](http://imgchr.lingwenlong.com/notes/img/20210531095212.png)

![](http://imgchr.lingwenlong.com/notes/img/20210531095413.png)

下面提交：

![](http://imgchr.lingwenlong.com/notes/img/20210531095531.png)
这时 文件提交到你的本地仓库,要想提交到远端仓库，还需要push

![](http://imgchr.lingwenlong.com/notes/img/20210531095740.png)

现在看下效果：
![](http://imgchr.lingwenlong.com/notes/img/20210531095830.png)


以上就是常用的git 操作。




## 使用 GUI 工具
这里给大家推荐使用 `TortoiseGit`
![](http://imgchr.lingwenlong.com/notes/img/20210531100514.png)
这个跟我们使用的 `svn` 工具很像，这里就不做介绍了。
