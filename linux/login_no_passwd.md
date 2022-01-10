---
title: SSH 免密认证
date: 2020-09-28
categories: 
    - devops
tags: [linux, ssh]
---


## a. 安装ssh

``` bash
sudo apt-get update
sudo apt-get install openssh-server
sudo apt-get install openssh-client
# 测试是否安装成功
ssh -l anxinyun 10.8.30.179
```
<!--more-->

## b. 修改配置

```
修改 /etc/ssh/sshd_config:
RSAAuthentication yes  (启用RSA认证)
PubkeyAuthentication yes (启用公钥私钥配对认证)
AuthorizedKeysFile      %h/.ssh/authorized_keys (公钥文件路径)
```

``` bash
# 重启服务
service ssh restart
```

## c. 配置密钥

``` bash
# 生成密钥对
# ssh-keygen -t rsa -P ""
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
# 输出到authorized_keys文件
cat .ssh/id_rsa.pub >> .ssh/authorized_keys
# 设置authorized_keys权限
chmod 600 .ssh/authorized_keys
```

``` bash
# 需要免密登录 哪台主机，就把公钥注册到哪台主机
# 复制 n1 公钥到 m1
scp anxinyun@10.8.30.179:/home/anxinyun/.ssh/id_rsa.pub .
# 追加到 authorized_keys
cat id_rsa.pub >> .ssh/authorized_keys
# 删除 n1 公钥
rm id_rsa.pub

# 在 n1、n2中重复上述命令
```

##  M1 远程登录免密

``` basic
用xshell 用户密钥生成工具生成密钥对
把公钥追加到 .ssh/authorized_keys 
私钥和密钥自己妥善保存

# 禁用ssh用户密码登录
修改 /etc/ssh/sshd_config:
  PasswordAuthentication no
```

