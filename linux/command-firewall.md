---
title: centos firewall 
date: 2020-09-27
categories: 
    - linux
tags: [linux, linux command]
---


#  firewall

## 简介

> FirewallD提供了支持网络/防火墙区域(zone)定义网络链接以及接口安全等级的动态防火墙管理工具。它支持IPv4, IPv6 防火墙设置以及以太网桥接，也支持允许服务或者应用程序直接添加防火墙规则的接口。FirewallD拥有运行时配置和永久配置选项.
>
<!--more-->
> 采用`firewall-cmd`(command)或`firewall-config`(gui)来动态的管理kernel netfilter的临时或永久的接口规则，并实时生效而无需重启服务.

##  特性

- `zone` : 作用域  
  
  提供以了下几个作用域:
  
  > `drop` :  任何流入网络的包都被丢弃，不作出任何响应，只允许流出的网络连接。即使开放了某些服务(比如http)，这些服务的数据也是不允许通过的
  >
  > `block` : 任何进入的网络连接都被拒绝，并返回IPv4的icmp-host-prohibited报文或者IPv6的icmp6-adm-prohibited报文. 只允许由该系统初始化的网络连接
  >
  > `public` : 默认, 用以可以公开的部分; 你认为网络中其他的计算机不可信并且可能伤害你的计算机，只允许选中的服务通过
  >
  > `external` : 用在路由器等启用伪装的外部网络。你认为网络中其他的计算机不可信并且可能伤害你的计算机，只允许选中的服务通过
  >
  > `dmz` : 用以允许隔离区(dmz)中的电脑有限地被外界网络访问，只允许选中的服务通过
  >
  > `work` : 用在工作网络。你信任网络中的大多数计算机不会影响你的计算机，只允许选中的服务通过
  >
  > `home` : 用在家庭网络。你信任网络中的大多数计算机不会影响你的计算机，只允许选中的服务通过
  >
  > `internal` : 用在内部网络。你信任网络中的大多数计算机不会影响你的计算机，只允许选中的服务通过
  >
  > `trusted` : 允许所有网络连接，即使没有开放任何服务，那么使用此zone的流量照样通过(一路绿灯)
  
- `预定义的服务`  : 端口和/或协议入口的组合

- `端口和协议 ` :  定义了tcp或udp端口，端口可以是一个端口或者端口范围

- `ICMP阻塞` :  可以选择Internet控制报文协议的报文。这些报文可以是信息请求亦可是对信息请求或错误条件创建的响应

- `伪装` :  私有网络地址可以被映射到公开的IP地址

- `端口转发` :  端口可以映射到另一个端口以及/或者其他主机

##  一般应用



```bash
# 停止firewall
systemctl stop firewalld.service             
# 禁止firewall开机启动
systemctl disable firewalld.service        

# 更新规则
firewall-cmd --reload

# 查看防火墙状态，是否是running
firewall-cmd --state 

# 更新规则, 重启服务
firewall-cmd --complete-reload

# 启用应急模式阻断所有网络连接，以防出现紧急状况
firewall-cmd --panic-on

# 禁用应急模式
firewall-cmd --panic-off

# 查询应急模式
firewall-cmd --query-panic

# 查看规则，这个命令是和iptables的相同的
iptables -L -n  

# 查看帮助
man firewall-cmd                               

```



##  作用域内应用



```bash
# 设置默认区域
firewall-cmd --set-default-zone=<zone>  [--permanent]
# 输出区域全部启用的特性。如果省略区域，将显示默认区域的信息
firewall-cmd [--zone=<zone>] --list-all

# 获取默认区域的网络设置
firewall-cmd --get-default-zone

# 设置public为默认的信任级别
firewall-cmd --set-default-zone=public 

# 列出全部启用的区域的特性
firewall-cmd --list-all-zones

# 列出支持的zone
firewall-cmd --get-zones [--permanent]

# 查看已被激活的zone信息
firewall-cmd --get-active-zones

# 查看指定级别的所有信息，譬如public
firewall-cmd --zone=public --list-all
```


###  端口管理

```bash
# 列出指定作用域的端口(默认 `public` )
firewall-cmd [--zone=<zone>] --list-ports
# 查询作用域中是否启用了端口协议组合
firewall-cmd [--zone=<zone>] --query-port=<port>[-<port>]/<protocol>
# 在指定作用域增加端口协议组合
firewall-cmd [--zone=<zone>] --add-port=<port>[-<port>]/<protocol> [--permanent]
# 在指定作用域移除端口协议组合
firewall-cmd [--zone=<zone>] --remove-port=<port>[-<port>]/<protocol> [--permanent]

#----------------------------
#
# 列出dmz级别的被允许的进入端口
firewall-cmd --zone=dmz --list-ports
#
# 允许tcp端口8080至dmz级别
firewall-cmd --zone=dmz --add-port=8080/tcp
#
# 永久添加80端口
firewall-cmd --add-port=80/tcp --permanent
```



### 服务管理

```bash
# 列出支持的服务，在列表中的服务是放行的  (永久放行的)
firewall-cmd [--zone=<zone>] --get-services [--permanent]
# 启用区域中的一种服务,如果设定了超时时间, 服务将只启用特定秒数
firewall-cmd [--zone=<zone>] --add-service=<service> [--timeout=<seconds>] [--permanent]
# 移除服务
firewall-cmd [--zone=<zone>] --remove-service=<service> [--timeout=<seconds>] [--permanent]
# 查询区域中是否启用了特定服务
firewall-cmd [--zone=<zone>] --query-service=<service>

# ---------------------------------
#
# 查看ftp服务是否支持，返回yes或者no
firewall-cmd --query-service ftp    
#
# 临时开放ftp服务
firewall-cmd --add-service=ftp    
#
# 永久开放ftp服务
firewall-cmd --add-service=ftp --permanent
#
# 永久移除ftp服务
firewall-cmd --remove-service=ftp --permanent
#
# 使区域中的ipp-client服务生效60秒
firewall-cmd --zone=home --add-service=ipp-client --timeout=60

```

### IP伪装和端口转发

```bash
# 查询作用域的伪装状态
firewall-cmd [--zone=<zone>] --query-masquerade [--permanent]
# 启用作用域中的IP伪装功能
firewall-cmd [--zone=<zone>] --add-masquerade [--permanent]
# 禁止作用域中防火墙伪装IP
firewall-cmd [--zone=<zone>] --remove-masquerade [--permanent]
# 启用端口转发或映射
firewall-cmd [--zone=<zone>] --add-forward-port=port=<port>[-<port>]:proto=<protocol> { :toport=<port>[-<port>] | :toaddr=<address> | :toport=<port>[-<port>]:toaddr=<address> } [--permanent]
# 禁用端口转发或映射
firewall-cmd [--zone=<zone>] --remove-forward-port=port=<port>[-<port>]:proto=<protocol> { :toport=<port>[-<port>] | :toaddr=<address> | :toport=<port>[-<port>]:toaddr=<address> } [--permanent]
# 查询端口转发或映射
firewall-cmd [--zone=<zone>] --query-forward-port=port=<port>[-<port>]:proto=<protocol> { :toport=<port>[-<port>] | :toaddr=<address> | :toport=<port>[-<port>]:toaddr=<address> } [--permanent]

# ----------------------
#
# 转发 80 至 192.168.0.1 的 8080 端口
firewall-cmd --add-forward-port=port=80:proto=tcp:toaddr=192.168.0.1:toport=8080 --permanent
# 将80端口的流量转发至8080
firewall-cmd --add-forward-port=port=80:proto=tcp:toport=8080 --permanent
# 将80端口的流量转发至 192.168.0.1
firewall-cmd --add-forward-port=port=80:proto=tcp:toaddr=192.168.0.1 --permanent
```



### 接口管理

```bash
# 修改接口所属区域
firewall-cmd [--zone=<zone>] --change-interface=<interface> [--permanent]
# 将接口增加到区域
firewall-cmd [--zone=<zone>] --add-interface=<interface> [--permanent]
# 从区域中删除一个接口
firewall-cmd [--zone=<zone>] --remove-interface=<interface> [--permanent]
# 查询区域中是否包含某接口
firewall-cmd [--zone=<zone>] --query-interface=<interface> [--permanent]

# -------------------------------------------
#
# 查看指定接口的zone信息
firewall-cmd --get-zone-of-interface=eth0
#
# 查看指定级别的接口
firewall-cmd --zone=public --list-interfaces
#
# 添加某接口至某信任等级，譬如添加eth0至public，再永久生效
firewall-cmd --zone=public --add-interface=eth0 --permanent
```

### ICMP

```bash

# 启用区域的ICMP阻塞功能
firewall-cmd [--zone=<zone>] --add-icmp-block=<icmptype> [--permanent]
# 禁止区域的ICMP阻塞功能
firewall-cmd [--zone=<zone>] --remove-icmp-block=<icmptype> [--permanent]
# 查询区域的ICMP阻塞功能
firewall-cmd [--zone=<zone>] --query-icmp-block=<icmptype> [--permanent]
# 获取所有支持的ICMP类型
firewall-cmd --get-icmptypes [--permanent]

# ---------------------------------------
#
# 阻塞区域的响应应答报文
firewall-cmd --zone=public --add-icmp-block=echo-reply

```

### 其他

```bash
# ----------------------------------
#
# IP封禁
firewall-cmd --permanent --add-rich-rule="rule family='ipv4' source address='222.222.222.222' reject"

```

## 直接选项

> 直接选项主要用于使服务和应用程序能够增加规则。 规则不会被保存，在重新加载或者重启之后必须再次提交。传递的参数`<args>`与iptables, ip6tables以及ebtables一致
>
> 选项`--direct`需要是直接选项的第一个参数

```bash
# 
firewall-cmd --direct --passthrough { ipv4 | ipv6 | eb } <args>
# 为表<table>增加一个新链<chain>
firewall-cmd --direct --add-chain { ipv4 | ipv6 | eb } <table> <chain>
# 从表<table>中删除链<chain>
firewall-cmd --direct --remove-chain { ipv4 | ipv6 | eb } <table> <chain>
# 查询<chain>链是否存在与表<table>
firewall-cmd --direct --query-chain { ipv4 | ipv6 | eb } <table> <chain>
# 获取用空格分隔的表<table>中链的列表
firewall-cmd --direct --get-chains { ipv4 | ipv6 | eb } <table>
# 为表<table>增加一条参数为<args>的链<chain> ，优先级设定为<priority>
firewall-cmd --direct --add-rule { ipv4 | ipv6 | eb } <table> <chain> <priority> <args>
# 从表<table>中删除带参数<args>的链<chain>
firewall-cmd --direct --remove-rule { ipv4 | ipv6 | eb } <table> <chain> <args>
# 查询带参数<args>的链<chain>是否存在表<table>中. 如果是返回0,否则返回1
firewall-cmd --direct --query-rule { ipv4 | ipv6 | eb } <table> <chain> <args>
# 获取表<table>中所有增加到链<chain>的规则，并用换行分隔
firewall-cmd --direct --get-rules { ipv4 | ipv6 | eb } <table> <chain>
```





