---
title: 初识 Raspberry Pi OS Lite
author: Uncle Dragon
date: 2021-07-13
categories: linux
tags:  [linux,containerd,mqtt]
---

<div align='center' ><b><font size='70'> 初识 Raspberry Pi OS Lite </font></b></div>























<center> author: Uncle Dragon </center>


<center>   date: 2021-07-13 </center>


<div STYLE="page-break-after: always;"></div>

[TOC]

<div STYLE="page-break-after: always;"></div>

 Raspberry Pi OS Lite  基于 Debian 10 32 位版本的精简版，因此debian 下默认使用的命令，绝大部分它都可以使用。

 # set up  Raspberry
 设置静态IP

```shell
$ vi /etc/dhcpcd.conf
 
interface eth0
static ip_address=10.8.30.100/24
static routes=10.8.30.1
static domain_name_servers=114.114.114.114 223.5.5.5 223.6.6.6
 
```


ssh 
 默认已经安装ssh服务
 设置开机自启
```shell
$ systemctl enable ssh
Synchronizing state of ssh.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable ssh
Created symlink /etc/systemd/system/sshd.service → /lib/systemd/system/ssh.service.
Created symlink /etc/systemd/system/multi-user.target.wants/ssh.service → /lib/systemd/system/ssh.service.
 
```

安装 vim

```shell
$ apt-get update && apt-get install vim

```


时区设置

```shell
$ apt-get install ntpdate

$ tzselect
Please identify a location so that time zone rules can be set correctly.
Please select a continent, ocean, "coord", or "TZ".
1) Africa							      5) Atlantic Ocean							   9) Pacific Ocean
2) Americas							      6) Australia							  10) coord - I want to use geographical coordinates.
3) Antarctica							      7) Europe								  11) TZ - I want to specify the time zone using the Posix TZ format.
4) Asia								      8) Indian Ocean
#? 4
Please select a country whose clocks agree with yours.
1) Afghanistan		   7) Brunei		    13) Hong Kong	      19) Japan			25) Kyrgyzstan		  31) Myanmar (Burma)	    37) Qatar		      43) Taiwan		49) Vietnam
2) Armenia		   8) Cambodia		    14) India		      20) Jordan		26) Laos		  32) Nepal		    38) Russia		      44) Tajikistan		50) Yemen
3) Azerbaijan		   9) China		    15) Indonesia	      21) Kazakhstan		27) Lebanon		  33) Oman		    39) Saudi Arabia	      45) Thailand
4) Bahrain		  10) Cyprus		    16) Iran		      22) Korea (North)		28) Macau		  34) Pakistan		    40) Singapore	      46) Turkmenistan
5) Bangladesh		  11) East Timor	    17) Iraq		      23) Korea (South)		29) Malaysia		  35) Palestine		    41) Sri Lanka	      47) United Arab Emirates
6) Bhutan		  12) Georgia		    18) Israel		      24) Kuwait		30) Mongolia		  36) Philippines	    42) Syria		      48) Uzbekistan
#? 9
Please select one of the following time zone regions.
1) Beijing Time
2) Xinjiang Time
#? 1

The following information has been given:

	China
	Beijing Time

Therefore TZ='Asia/Shanghai' will be used.
Selected time is now:	Mon Jul 12 17:33:01 CST 2021.
Universal Time is now:	Mon Jul 12 09:33:01 UTC 2021.
Is the above information OK?
1) Yes
2) No
#? 1

You can make this change permanent for yourself by appending the line
	TZ='Asia/Shanghai'; export TZ
to the file '.profile' in your home directory; then log out and log in again.

Here is that TZ value again, this time on standard output so that you
can use the /usr/bin/tzselect command in shell scripts:
Asia/Shanghai

$ vi /etc/profile

TZ='Asia/Shanghai'; export TZ

$ source /etc/profile

$ date
Mon 12 Jul 17:36:07 CST 2021
```


# install containerd

```shell
$ sudo apt-get update
    
$ sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
```


```shell
$ curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```



```shell
$ echo \
  "deb [arch=armhf signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

```shell
$ sudo apt-get update
$ sudo apt-get install containerd.io
```

# install mqtt

```shell


wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key

sudo apt-key add mosquitto-repo.gpg.key

# sudo wget -P /etc/apt/sources.list.d/ http://repo.mosquitto.org/debian/mosquitto-jessie.list
# sudo wget -P /etc/apt/sources.list.d/ http://repo.mosquitto.org/debian/mosquitto-stretch.list
sudo wget -P /etc/apt/sources.list.d/ http://repo.mosquitto.org/debian/mosquitto-buster.list 

apt-get update

apt-get install mosquitto


```



