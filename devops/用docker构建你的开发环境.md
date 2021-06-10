
# 启用WSL
# 在windows 商店安装 ubuntu 20.04
# 在vs code 中安装 `Remote - WSL`
 ![](http://imgchr.lingwenlong.com/notes/img/20210414103854.png)

# 使用 WSL 

 ![](http://imgchr.lingwenlong.com/notes/img/20210414103943.png)

 ![](http://imgchr.lingwenlong.com/notes/img/20210414103959.png)

选择第一项，vs code  会打开一个新的窗口， 在左下角提示当前连接的WSL

 ![](http://imgchr.lingwenlong.com/notes/img/20210414105642.png)

右侧终端就是 WSL 子系统的终端

 ![](http://imgchr.lingwenlong.com/notes/img/20210414105749.png)

下面在这里安装 nvm 和 node

```shell
sudo apt-get update

wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

```
 ![](http://imgchr.lingwenlong.com/notes/img/20210414110330.png)

```shell
source .bashrc
```

下面就可以使用nvm 了：

```shell

nvm install 12.22.1

nvm use 12.22.1

```

 ![](http://imgchr.lingwenlong.com/notes/img/20210414110521.png)

设置npm 源
```shell
npm config set registry=http://10.8.30.22:7000
```
 ![](http://imgchr.lingwenlong.com/notes/img/20210414111412.png)

下面就可以在 WSL 中开发调试node 程序了
 ![](http://imgchr.lingwenlong.com/notes/img/20210414111015.png)

这样就跟在本地开发一样了：
 ![](http://imgchr.lingwenlong.com/notes/img/20210414111637.png)