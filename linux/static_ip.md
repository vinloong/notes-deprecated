---
title: Linux 设置静态 IP
date: 2020-05-26
categories: 
    - linux
tags: [linux]
---

## Ubuntu 

### Ubuntu 16 
####  修改 `/etc/network/interfaces`

``` bash
sudo vi  /etc/network/interfaces
```

<!--more-->

``` ini
auto eno4
iface eno4 inet static
address 10.8.30.176
netmask 255.255.255.0
gateway 10.8.30.1
dns-nameserver 114.114.114.114
```

### Ubuntu 18.04 +

> 原来设置 `/etc/network/interfaces` 的方法还可以用，只是设置的dns没有用
> 新的配置使用 netplan 管理

#### 修改配置文件

> 编辑 `/etc/netplan/`下的yaml文件
>
> 这里文件名是 `01-network-manager-all.yaml`

```bash
sudo vi /etc/netplan/01-network-manager-all.yaml

# 注释掉 renderer:NetworkManager

network:
	version: 2
	ethernets: 
		# 网络名
		enp0s3:
			# 一个ip数组，用 ‘,’ 隔开
			addresses: [10.8.40.119/24]
			# 使用dhcp 动态获取ip: true/no
			dhcp4: no
			# ipv4 网关
			gateway4: 192.168.0.1
			# dns
			nameservers: 
				addresses: [114.114.114.114]
				search: [localdomain]
			optional: true

# 立即生效
sudo netplan apply
```

### 补充

#### 查看网关

```bash
# 查看网关
netstat -rn 
# 或
route -n

```

#### 设置默认网关
``` bash
route add default gw 10.8.30.1
```

#### 重启网关
``` bash
/etc/init.d/networking restart
```

### 配置 `/etc/resolv.conf`
> 以上配置完成就可以了
> 如果是desktop 版本可能设置的dns不能使 /etc/resolv.conf生效. 重启又恢复到默认

#### 安装 resolvconf 服务

```bash
sudo apt-get update
sudo apt-get install resolvconf
```

#### 配置 resolvconf

> 修改 /etc/resolvconf/resolv.conf.d/head

```bash
vi /etc/resolvconf/resolv.conf.d/head
# 增加
nameserver 223.5.5.5
nameserver 223.6.6.6
```

> 保存退出，执行

```bash
resolvconf -u
```

> 查看 /etc/resolv.conf, 重启再看

```bash
cat /etc/resolv.conf
```

## CentOS

>
>配置文件在 `/etc/sysconfig/network-scripts ` 下
>
>这里测试机文件名为：ifcfg-enp0s3
>
>修改 ifcfg-enp0s3 文件

```bash
vi /etc/sysconfig/network-scripts/ifcfg-enp0s3
```

> 默认配置

```bash
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=enp0s3
UUID=64a31304-95d8-4ab6-961e-8d5db92f8cc0
DEVICE=enp0s3
ONBOOT=no
```

> 修改为

```bash
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
#BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=enp0s3
UUID=64a31304-95d8-4ab6-961e-8d5db92f8cc0
DEVICE=enp0s3
#ONBOOT=no

#static assignment
NM_CONTROLLED=no
ONBOOT=yes
BOOTPROTO=static
IPADDR=192.168.0.116
NETMASK=255.255.255.0
GATEWAY=192.168.0.1

```



> 修改/etc/sysconfig/network

> 默认为空

```bash
# Created by anaconda
NETWORKING=yes
GATEWAY=192.168.0.1
DNS1=114.114.114.114
```

> 重启服务

```bash
service network restart
```

