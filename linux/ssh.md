---
title: ssh 命令解析
date: 2021-06-09
categories: 
    - linux
tags: [ssh]
---

安装和配置参考：[免密配置](linux/login_no_passwd.md)
本文主要介绍 `ssh` 的功能使用

```shell
usage: ssh [-46AaCfGgKkMNnqsTtVvXxYy] [-b bind_address] [-c cipher_spec]
           [-D [bind_address:]port] [-E log_file] [-e escape_char]
           [-F configfile] [-I pkcs11] [-i identity_file]
           [-J [user@]host[:port]] [-L address] [-l login_name] [-m mac_spec]
           [-O ctl_cmd] [-o option] [-p port] [-Q query_option] [-R address]
           [-S ctl_path] [-W host:port] [-w local_tun[:remote_tun]]
           [user@]hostname [command]

```

# 登录
> ssh -p 22 {{user}}@{{host-ip}}

```shell
ssh -p 22 test@test-n1

```

## 密钥登录

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191056364.png)
> 信息提示大意是密钥文件的权限太过开放了
> 修改下权限只能自己访问就可以了


# FAQ
1. no hostkeys available— exiting
   root权限下，重新生成密钥：
	```shell
	ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
	
	chmod 600 /etc/ssh/ssh_host_dsa_key
	chmod 600 /etc/ssh/ssh_host_rsa_key
	```
2.   