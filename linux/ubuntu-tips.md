---
title: Ubuntu 使用中的一些小技巧
date: 2020-04-22
categories: 
    - linux
tags: [linux]
---

## 1. 更换软件源

> 众所周知由于国内的网络原因，有时候下载安装软件比较慢,使用国内的软件源速度就会好很多  
> 常用的镜像站：  
> - http://mirrors.163.com
> - https://mirrors.tuna.tsinghua.edu.cn/
> - https://mirrors.huaweicloud.com/
> - https://mirrors.ustc.edu.cn/  
> - https://mirrors.aliyun.com/

<!--more-->

```bash

# 备份默认的文件
cp /etc/apt/sources.list /etc/apt/sources.list.bak

sed -i "s@http://.*archive.ubuntu.com@http://mirrors.huaweicloud.com@g" /etc/apt/sources.list
sed -i "s@http://.*security.ubuntu.com@http://mirrors.huaweicloud.com@g" /etc/apt/sources.list
```

## 2. 启用  `root` 用户
>  `ubuntu` 默认是禁用`root`的，如果想要启用`root`用户,需进行下列操作


```bash
# 修改 /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf 文件
# 添加一行：greeter-show-manual-login=true
$ sudo vi /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
greeter-show-manual-login=true  
# 或
$ sudo echo "greeter-show-manual-login=true" >> /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf


# 设置root密码
sudo passwd root


#  mesg n 替换成 tty -s && mesg n
sudo vi /root/.profile
#  mesg n   >>   tty -s && mesg n
```

## 3. `sudo` 免密

> 平时使用 `sudo` 是需要输入密码的，输入次数太多，比较烦，有什么办法可以不用输入密码呢？
>
> 修改下面配置，免除输入密码，一次修改，一劳永逸（不建议在生产环境配置）

> - 1  先修改 `sudoers` 文件权限

```bash
# 查看 sudoers 默认权限
:~$ ll /etc/sudoers
-r--r----- 1 root root 755 Jan 18  2018 /etc/sudoers
:~$ sudo chmod u+w /etc/sudoers
[sudo] password for dragon: # 输入密码
# 查看 sudoers 修改后的权限
:~$ ll /etc/sudoers
-rw-r----- 1 root root 755 Jan 18  2018 /etc/sudoers
```

> - 2  修改 `sudoers` 文件

 ```bash
# 在文件中增加一行 ${username} ALL=(ALL) NOPASSWD : ALL
:~$ sudo vi /etc/sudoers
#
# This file MUST be edited with the 'visudo' command as root.
# ... ...
# See the man page for details on how to write a sudoers file.
#
# ... ... 中间省略一千字
#
# 下面是增加的行
dragon ALL=(ALL) NOPASSWD : ALL
 ```

> - 3. 恢复 `sudoers` 权限

```bash
:~$ sudo chmod u-w /etc/sudoers
:~$ ll /etc/sudoers
-r--r----- 1 root root 828 May 26 00:40 /etc/sudoers
```

> 大功告成 . 

## 4. 查看系统运行时间，负载 

> 有时候我们想知道刺痛上一次复位时什么时候，或者系统已经运行了多长时间了，我们可以通过`uptime` 命令来获取这些信息

```bash
$ uptime
 19:38:29 up 50 min,  1 users,  load average: 0.52, 0.58, 0.59
```
> 从左往右显示的信息依次是：当前时间，已运行时间，登录用户数，1分钟、5分钟、15分钟内系统的平均负载

## 5. 查看当前登录的用户
```bash
$ who 
test tty7         2019-12-24 17:56 (:0)
```
> 后面加参数 ``--ips` 还可以看到哪个ip登录这台主机

## 6. 查看目录和文件占用空间

> `du`命令直接显示当前目录下每个目录及其文件占用空间。结合`--max-depth`参数可以指定显示的目录层级
```bash
$ du -h --max-depth=1 
19M        ./python
9.0M        ./git
321M        ./hexo
17M        ./lua
28K        ./vim
1.4M        ./shell
81M        ./redis
316M        ./books
48M        ./c
810M        .
$ du -sh     #仅统计当前目录总大小
810M
```
> 其中`-h`表示以易读的单位显示大小，即`M`，`--max-depth=1`表明目录层级
> 通过命令结果，我们可以看到当前目录下各个子目录占用空间大小，以及总空间大小

## 7. 查看 cpu 信息
> 直接使用 `cat /proc/cpuinfo`  命令会输出cpu 的所有信息
> 配合 `grep` 只输出我们需要的信息

```bash
# 逻辑CPU个数
$ cat /proc/cpuinfo | grep "processor" | wc -l
4
# 物理CPU个数
$ cat /proc/cpuinfo | grep "physical id" | sort -u | wc -l
1
# 每个物理CPU中Core的个数
$ cat /proc/cpuinfo | grep "cpu cores" | uniq | awk -F: '{print $2}'
 4
# 查看core id的数量,即为所有物理CPU上的core的个数
$ cat /proc/cpuinfo | grep "core id" | uniq | wc -l
4
# 查看cpu型号
$ cat /proc/cpuinfo | grep 'model name' |uniq
model name	: Intel(R) Xeon(R) CPU E5-2403 v2 @ 1.80GHz
```
> 判断有几个物理CPU/几核/几线程  
> 判断依据：  
> 1.具有相同core id的cpu是同一个core的超线程  
> 2.具有相同physical id的cpu是同一颗cpu封装的线程或者cores

## 8. 查看内核版本

```bash
$ cat /proc/version
Linux version 4.4.0-170-generic (buildd@lcy01-amd64-019) (gcc version 5.4.0 20160609 (Ubuntu 5.4.0-6ubuntu1~16.04.12) ) #199-Ubuntu SMP Thu Nov 14 01:45:04 UTC 2019
$ uname -a
Linux anxinyun-m1 4.4.0-170-generic #199-Ubuntu SMP Thu Nov 14 01:45:04 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
$ uname -r
4.4.0-170-generic

```

## 9. 查看发行版及其版本号

```bash
$ cat /etc/issue
Ubuntu 16.04.5 LTS \n \l

$ cat /etc/lsb-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=16.04
DISTRIB_CODENAME=xenial
DISTRIB_DESCRIPTION="Ubuntu 16.04.5 LTS"

$ lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 16.04.5 LTS
Release:	16.04
Codename:	xenial

```