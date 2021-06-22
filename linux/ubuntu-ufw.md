---
title: ubuntu 如何配置防火墙
author: Uncle Dragon
date: 2021-06-22
categories: linux
tags: [ubuntu,ufw]
---

<div align='center' ><b><font size='70'> ubuntu 如何配置防火墙 </font></b></div>























<center> author: Uncle Dragon </center>


<center>   date: 2021-06-22 </center>


<div STYLE="page-break-after: always;"></div>

[TOC]

<div STYLE="page-break-after: always;"></div>


# 简介
UFW（Uncomplicated Firewal）是 Ubuntu 下基于 iptables 的接口，旨在简化配置防火墙的过程。默认情况下 UFW 为开启状态，开启时默认为拒绝所有传入链接，并允许所有传出连接。这意味着任何人尝试到达您的服务器将无法连接，而服务器内的任何应用程序能够达到外部世界。
 
 # 安装
 一般情况 ubuntu 默认已经安装
 
 ```shell
 sudo apt-get install ufw
 ```
 
 # 常用命令
 
 ## 查看服务是否已启动及防火墙规则
 
```shell
# 激活：已启动 不激活：已关闭
sudo ufw status

# 查看详细信息
sudo ufw status verbose

# 查看带编号的服务信息 [用于 remove 时的编号参数]
sudo ufw status numbered
```

## 开启关闭防火墙

```shell
# 关闭防火墙
sudo ufw disable

# 启动防火墙
sudo ufw enable
```

## 设置默认策略
```shell
# 默认禁止所有其它主机连接该主机
sudo ufw default deny incoming

# 默认允许该主机所有对外连接请求
sudo ufw default allow outgoing
```

## 设置允许连接规则
```shell
# 允许 ssh 服务（服务名）
sudo ufw allow ssh

# 允许 ssh 服务（端口号）
sudo ufw allow 22

# 允许特定协议的端口访问
sudo ufw allow 21/tcp

# 允许特定端口范围
sudo ufw allow 6000:6007/tcp
sudo ufw allow 6000:6007/udp

# 允许特定IP地址访问
sudo ufw allow from 192.168.1.100

# 允许特定范围主机（15.15.15.1 - 15.15.15.254）
sudo ufw allow from 15.15.15.0/24

# 允许特定范围主机访问特定端口
sudo ufw allow from 15.15.15.0/24 to any port 22

# 允许连接到特定的网卡
sudo ufw allow in on eth0 to any port 80
```

## 设置拒绝连接规则
```shell
# 将 allow 替换为 deny
sudo ufw deny http
sudo ufw deny from 192.168.1.100
```

## 删除规则
```shell
# 查看所有规则并显示规则编号
sudo ufw status numbered

# 按编号删除
sudo ufw delete allow 2

# 按服务删除
sudo ufw delete allow ssh
```


## 重置 ufw

```shell
# 恢复至初始状态
sudo ufw reset
```

# 配置
## 修改配置文件
```shell
# 打开配置文件
sudo vi /etc/default/ufw

# 命令操作同时对IPv4和IPv6都生效
IPV6=yes
```

## 配置生效
```shell
# 重启防火墙
sudo ufw disable
sudo ufw enable
```

