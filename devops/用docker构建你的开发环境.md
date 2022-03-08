# 启用WSL

# 在windows 商店安装 ubuntu 20.04
# 在vs code 中安装 `Remote - WSL`
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191002205.png)

# 使用 WSL 

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191002859.png)

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191003747.png)

选择第一项，vs code  会打开一个新的窗口， 在左下角提示当前连接的WSL

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191003875.png)

右侧终端就是 WSL 子系统的终端

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191003463.png)

下面在这里安装 nvm 和 node

```shell
sudo apt-get update

wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

```
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191004165.png)

```shell
source .bashrc
```

下面就可以使用nvm 了：

```shell

nvm install 12.22.1

nvm use 12.22.1

```

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191004940.png)

设置npm 源
```shell
npm config set registry=http://10.8.30.22:7000
```
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191005636.png)

下面就可以在 WSL 中开发调试node 程序了
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191005770.png)

这样就跟在本地开发一样了：
 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191005542.png)