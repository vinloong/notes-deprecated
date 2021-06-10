---
title: Ubuntu 中安装 Docker CE
date: 2020-03-28
categories: 
    - k8s&docker
tags: [docker,ubuntu]
---

## 准备工作

- 系统要求
  - ununtu 16.04 LTS 
- 卸载旧版本

<!--more-->

> 如果安装有旧版本的docker(旧版本的 Docker 称为 `docker` 或者 `docker-engine`) ，先卸载它
```bash
$ sudo apt-get remove docker docker-engine docker.io containerd runc
```

## 1. 安装
### 1.1 使用 `apt` 安装

> 由于 `apt` 源使用 HTTPS 以确保软件下载过程中不被篡改。因此，我们首先需要添加使用 HTTPS 传输的软件包以及 CA 证书

```bash
$ sudo apt-get update

$ sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
```

> 为了确认所下载软件包的合法性，需要添加软件源的 GPG 密钥。

> 鉴于国内网络问题，建议使用国内源，注释部分是官方源

```bash
# 官方源
# $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# 中科大的源
$ curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
```

> 下面添加 docker 软件源
```bash
# $ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
$ sudo add-apt-repository "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
```
> 以上命令会添加稳定版本的 Docker CE APT 镜像源，如果需要测试或每日构建版本的 Docker CE 请将 stable 改为 test 或者 nightly。

> 更新 apt 软件包缓存，并安装 `docker-ce`

```bash
$ sudo apt-get update
$ sudo apt-get install docker-ce docker-ce-cli containerd.io
```

> 注：也可以指定版本安装
```
# $ apt-cache madison docker-ce
# $ sudo apt-get install docker-ce=<VERSION_STRING> docker-ce-cli=<VERSION_STRING> containerd.io
$ sudo docker run hello-world
```
### 1.2  手动安装
```bash
# https://download.docker.com/linux/ubuntu/dists/ 在这里选择下载安装包
$ sudo dpkg -i /path/to/package.deb
```
### 1.3 使用脚本自动安装

```bash
$ curl -fsSL https://get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh
# $ sudo sh get-docker.sh --mirror Aliyun
# $ sudo sh get-docker.sh --mirror AzureChinaCloud
```

### 1.4 测试安装成功





## 2 使用非 `root` 用户管理 docker



###  2.1 创建 docker 用户组

> 现在安装完成，会自动创建docker 用户组

```bash
# $ sudo groupadd docker
# 将当前用户添加到 docker 组
$ sudo usermod -aG docker $USER
```
> 重新登录，进行测试
```bash
$ newgrp docker 
$ docker run hello-world
```
> 如果遇到以下错误提示：
```bash
WARNING: Error loading config file: /home/user/.docker/config.json -
stat /home/user/.docker/config.json: permission denied
```
两个方法解决：
> 1. 把 用户目录下的 `.docker` 文件夹删除
> 2. 使用下面的命令修复
```bash
$ sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
$ sudo chmod g+rwx "$HOME/.docker" -R
```

## 3 配置docker 自启

```bash
$ sudo systemctl enable docker
# 取消自启
$ sudo systemctl disable docker
```

## 4 配置镜像加速

> 前面看到了我们使用镜像时，镜像拉取特别慢，有些甚至无法获取。这时候我们可以配置镜像加速。
>
> 国内一些云服务商提供了国内的镜像加速服务
>
> 如：

- [Azure 中国镜像 `https://dockerhub.azk8s.cn`](https://github.com/Azure/container-service-for-azure-china/blob/master/aks/README.md#22-container-registry-proxy)
- [阿里云加速器(需登录账号获取)](https://cr.console.aliyun.com/cn-hangzhou/mirrors)
- [网易云加速器 `https://hub-mirror.c.163.com`](https://www.163yun.com/help/documents/56918246390157312)

### 4.1 配置
> - 新的版本修改配置文件 `/etc/docker/daemon.json` ：

```json
{
  "registry-mirrors": [
    "https://dockerhub.azk8s.cn",
    "https://hub-mirror.c.163.com",
    "https://ktrsh7na.mirror.aliyuncs.com"
  ]
}
```

> - 老版教程 编辑  `/etc/systemd/system/multi-user.target.wants/docker.service` 文件

```bash
# 找到  ExecStart= 追加  --registry-mirror=https://ktrsh7na.mirror.aliyuncs.com

```

> 注意： 上面提到的两种方法，只能使用一种，不能同时修改

> 然后重启docker服务

```bash
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker
```

> 下面检查加速器是否生效

```bash
$ docker info
```

### 4.2 应用

> 国内无法直接获取 `gcr.io/*` 镜像，我们可以将 `gcr.io//:` 替换为 `gcr.azk8s.cn//:` 

```bash
# $ docker pull gcr.io/google_containers/hyperkube-amd64:v1.9.2
$ docker pull gcr.azk8s.cn/google_containers/hyperkube-amd64:v1.9.2
```



## 5 卸载docker

```bash
$ sudo apt-get purge docker-ce
# 上面命令不会自动删除 主机上的镜像、容器、卷或自定义配置文件。 删除所有镜像、容器和卷
$ sudo rm -rf /var/lib/docker
```

