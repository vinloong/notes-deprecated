---
title: docker 使用中遇到的问题汇总
date: 2020-04-18
categories: 
    - k8s&docker
tags: [docker]
---

## Q1: 
> jenkins in docker 遇到如下错误：
```
ERROR: Build step failed with exception
net.sf.json.JSONException: A JSONObject text must begin with '{' at character 0 of at net.sf.json.util.JSONTokener.syntaxError(JSONTokener.java:499)
```

<!--more-->

> 进入jenkins 容器，进入jenkins 主目录, 删除 `.docker` 目录

```bash
$ docker exec -it {{container}} /bin/bash

{{container}} $ cd 
{{container}} $ rm -rf .docker .dockercfg
```

## Q2: 
> windows 下使用 `Dockers-Desktop` 时，已经启用了 `Hyper-V`,打开 `Dockers-Desktop` 时还是会报错，不能正常使用

管理员身份运行命令行程序：

```cmd 
 dism.exe /Online /Enable-Feature:Microsoft-Hyper-V /All

 bcdedit /set hypervisorlaunchtype auto
```

## Q3: 
>    docker login 登录镜像仓库时,密码正确但报如下错误：
```
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
Error saving credentials: error storing credentials - err: exit status 1, out: `Cannot autolaunch D-Bus without X11 $DISPLAY`
```
> 解决方案：安装 `gnupg2` 和 `pass`
 ```bash
sudo apt install gnupg2 pass
```

## Q4: 
> 容器内部不能读取处理中文
```shell
# 进入容器前添加环境变量
$ docker exec -it <container> env LANG=C.UTF-8 bash
```


## Q5:
> docker 无法自动补全命令怎么办？
```shell
# 1. 安装 bash-completion
# ubuntu 
$ apt-get -y install bash-completion
# centos
$ yum install -y bash-completion

# 2. 刷新文件
$ source /usr/share/bash-completion/completions/docker
$ source /usr/share/bash-completion/bash-completion

```