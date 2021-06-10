---
title: ubnunru 启用 root 用户登录
date: 2020-05-26
categories: 
    - devops
tags: [linux]
---


#  ubnunru 启用`root`用户登录

## 1.

``` bash

# 添加一行：greeter-show-manual-login=true
> sudo vi /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
## greeter-show-manual-login=true  

# 设置root密码
sudo passwd root

#  mesg n 替换成 tty -s && mesg n
sudo vi /root/.profile
#  mesg n   >>   tty -s && mesg n 

```

## 2. 启用 root 用户ssh远程

``` bash
vim /etc/ssh/sshd_config
#PermitRootLogin without-password，添加 PermitRootLogin yes

```

# 修改用户名

``` bash
# testerone 修改为 anxin
 usermod -l anxin testerone

# 修改主目录
usermod -d /home/anxin anxin

# 修改用户组
groupmod -n anxin testerone

```