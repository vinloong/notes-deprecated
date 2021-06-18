---
title: containerd 入门
author: Uncle Dragon
date: 2021-06-16
categories: k8s
tags: [k8s,containerd]
---

<div align='center' ><b><font size='70'>containerd 入门</font></b></div>























<center> author: Uncle Dragon </center>


<center>   date: 2021-06-16 </center>


<div STYLE="page-break-after: always;"></div>

[TOC]

<div STYLE="page-break-after: always;"></div>

## 安装之前

```shell
$ cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

$ sudo modprobe overlay
$ sudo modprobe br_netfilter


# 设置必需的 sysctl 参数，这些参数在重新启动后仍然存在。
$ cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# 应用 sysctl 参数而无需重新启动
$ sudo sysctl --system

```


## 安装 containerd
### 1. 从官方Docker仓库安装
参考 [docker的安装](https://docs.docker.com/engine/install/ubuntu/)
你没看错 就是 `docker` 的安装文档，我们只安装 `containerd.io` 就好

```shell
$ sudo apt-get update

$ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

$ echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


$ sudo apt-get update

$ sudo apt-get install containerd.io

```

### 2. 下载 containerd 二进制文件，手动安装

```shell

# 下载链接
$ wget https://github.com/containerd/containerd/releases/download/v1.5.2/containerd-1.5.2-linux-amd64.tar.gz

# 解压二进制包并生成默认文件
$ tar xvf containerd-1.5.2-linux-amd64.tar.gz -C /usr/local/

# 创建目录
$ mkdir /etc/containerd

# 在创建的目录中生成配置文件
$ containerd config default> /etc/containerd/config.toml

```

配置 `containerd` 服务

```shell

$ sudo cat <<EOF | sudo tee /lib/systemd/system/containerd.service
> [Unit]
> Description=containerd container runtime
> Documentation=https://containerd.io
> After=network.target local-fs.target
> 
> [Service]
> ExecStartPre=-/sbin/modprobe overlay
> ExecStart=/usr/local/bin/containerd
> 
> Type=notify
> Delegate=yes
> KillMode=process
> Restart=always
> RestartSec=5
>
> LimitNPROC=infinity
> LimitCORE=infinity
> LimitNOFILE=1048576
>
> TasksMax=infinity
> OOMScoreAdjust=-999
> 
> [Install]
> WantedBy=multi-user.target
> EOF

```

配置服务开机自启

```shell

$ systemctl enable containerd 

$ systemctl start containerd 

$ systemctl status containerd

```

## 配置

```shell
$ sudo mkdir -p /etc/containerd
$ containerd config default | sudo tee /etc/containerd/config.toml
```

结合 `runc` 使用 `systemd` cgroup 驱动，在 `/etc/containerd/config.toml` 中设置

```
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
```

重新启动 containerd

```shell
$ sudo systemctl restart containerd
```

## 测试
```shell
$ ctr version
Client:
  Version:  1.4.6
  Revision: d71fcd7d8303cbf684402823e425e9dd2e99285d
  Go version: go1.13.15

Server:
  Version:  1.4.6
  Revision: d71fcd7d8303cbf684402823e425e9dd2e99285d
  UUID: 2ba390eb-5ebf-49ae-a931-fa3ec68bb8aa

```



## 使用

- ctr 是 `containerd` 本身的车重
- crictl 是 k8s 社区定义的专门的 CLI 工具



