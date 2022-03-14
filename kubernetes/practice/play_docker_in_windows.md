---
title: 在windows 下使用 docker
date: 2020-09-27
categories: 
    - devops
tags: [docker,wsl]
---

## 升级WSL

> 检查你的系统版本号
>
> 设置 > 更新和安全 > OS 内部版本信息

<!--
整段整段的不可见内容
`http://island.lingwenlong.com/notes/img/20200909141750.png`


`http://island.lingwenlong.com/notes/img/20200909142232.png`

-->

如果你的版本号低于这个，推荐更新安装Windows 10 2020 年 5 月更新，[更新助手](https://download.microsoft.com/download/8/3/c/83c39dca-2d27-4c24-b98b-0a4d6d921c80/Windows10Upgrade9252.exe)。

为什么推荐更新到2004：为了使用 WSL 2 

为啥使用 WLS 2 , windows docker desktop 不行吗？

> window docker desktop 需要启用 Hyper-V ,这玩意儿装一坨东西，自己又不咋用，跟第三方的虚拟机软件不兼容

# 安装WSL 2

1. 启用“ *虚拟机平台(Virtual Machine Platform)*”可选组
2. 下载并安装更新组件：https://aka.ms/wsl2kernel
3. 

```cmd
wsl --set-default-version 2

# 查看有已安装的子系统
wsl -l -v
  NAME            STATE           VERSION
* Ubuntu-18.04    Stopped         2
  kali-linux      Running         2

# 迁移到version2
wsl --set-version Ubuntu-18.04 2

```

后面没有安装子系统的可以到win10 的 Microsoft Store 下载 安装就好。




# 使用

## [简单配置优化](http://blog.lingwenlong.com/2020/04/22/ubuntu-tips/)

### 使用xshell 连接

> 子系统自己的终端不好用，配置下使用xhell 来连接使用

修改 ssh 配置

```bash
> sudo vi /etc/ssh/sshd_config
Port 1022
PasswordAuthentication yes

> sudo service ssh restart
# 这里可能会报错 error: Could not load host key: /etc/ssh/ssh_host_rsa_key ...

ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key 
ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
```

## [安装 docker](http://blog.lingwenlong.com/2020/03/28/docker-install/)


### 补充

> 由于子系统中不支持自启程序

> 在 ubuntu 中 编写初始化脚本

 ```bash
> sudo vi /etc/init.sh

#!/bin/bash

service ssh start && service docker start

> chmod +x /etc/init.sh
 ```

> 在 windows 下创建启动脚本 start-ubuntu.bat(start-ubuntu.cmd)

```cmd
@echo off

wsl --shutdown
wsl -d Ubuntu-20.04 -u root /etc/init.sh
```

> 后面每次启动后执行下这个脚本，就可以了



> 想设置开机自启：WIN + R 输入 `shell:startup` , 把脚本放进去，就可以了

