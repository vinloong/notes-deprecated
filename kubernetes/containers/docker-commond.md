---
title: docker 容器管理常用命令解析
date: 2020-04-05
categories:
    - k8s&docker
tags: [docker]
---

## 1 容器生命周期管理

### run

  **语法**

```bash
 $ docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
```

<!--more-->

> OPTIONS说明：
> 
> - **`-d`:** 后台运行容器，并返回容器ID；
> - **`-i`:** 以交互模式运行容器，通常与 -t 同时使用；
> - **`-P`:** 随机端口映射，容器内部端口**随机**映射到主机的高端口
> - **`-p`:** 指定端口映射，格式为：**主机(宿主)端口:容器端口**
> - **`-t`:** 为容器重新分配一个伪输入终端，通常与 -i 同时使用；
> - **`--name`:** 为容器指定一个名称；
> - **`--link`:** 添加链接到另一个容器；
> - **`--expose`:** 开放一个端口或一组端口；
> - **`--volume` , `-v`:** 绑定一个卷

 **实例**

```bash
$ docker run --name myghost -d ghost:latest

$ docker run -P -d ghost:latest

$ docker run -p 8000:2368 -d ghost:last

$ docker run -it ghost:last /bin/bash
```

> 当利用 `docker run` 来创建容器时，Docker 在后台运行的标准操作包括：
> 
> - 检查本地是否存在指定的镜像，不存在就从公有仓库下载
> - 利用镜像创建并启动一个容器
> - 分配一个文件系统，并在只读的镜像层外面挂载一层可读写层
> - 从宿主主机配置的网桥接口中桥接一个虚拟接口到容器中去
> - 从地址池配置一个 ip 地址给容器
> - 执行用户指定的应用程序
> - 执行完毕后容器被终止

### start/stop/restart

> **docker start** :启动一个或多个已经被停止的容器
> 
> **docker stop** :停止一个运行中的容器
> 
> **docker restart** :重启容器

  **语法**

```bash
$ docker start [OPTIONS] CONTAINER [CONTAINER...]
$ docker stop [OPTIONS] CONTAINER [CONTAINER...]
$ docker restart [OPTIONS] CONTAINER [CONTAINER...]
```

  **实例**

```bash
$ docker start myghost
$ docker stop myrunoob
$ docker restart myrunoob
```

### rm

> **docker rm ：**删除一个或多个容器。

  **语法**

```bash
$ docker rm [OPTIONS] CONTAINER [CONTAINER...]
```

> OPTIONS说明：
> 
> - **-f :**通过 SIGKILL 信号强制删除一个运行中的容器。
> - **-l :**移除容器间的网络连接，而非容器本身。
> - **-v :**删除与容器关联的卷。

  **实例**

```bash
$ docker rm -f myghost

# 删除所有已经停止的容器
$ docker rm $(docker ps -a -q)
# 清理所有处于终止状态的容器
$ docker container prune
```

## 2 容器操作

### ps

> **docker ps :** 列出容器

  **语法**

```bash
$ docker ps [OPTIONS]
```

> OPTIONS说明：
> 
> - **-a :**显示所有的容器，包括未运行的。
> - **-f :**根据条件过滤显示的内容。
> - **--format :**指定返回值的模板文件。
> - **-l :**显示最近创建的容器。
> - **-n :**列出最近创建的n个容器。
> - **--no-trunc :**不截断输出。
> - **-q :**静默模式，只显示容器编号。
> - **-s :**显示总的文件大小。

  **实例**

```bash
$ docker ps
```

```
CONTAINER ID    IMAGE        COMMAND                CREATED                    STATUS        PORTS        NAMES
31948620b4e9    ubuntu        "/bin/bash"            33 seconds ago        Up 32 seconds                 infallible_mahavira
908dae191777   ghost:v3   "docker-entrypoint.s…"    3 hours ago  Up 3 hours    2368/tcp  condescending_sutherland
e87b3c175433   ghost:v2   "docker-entrypoint.s…"   3 hours ago  Up 3 hours    2368/tcp    eloquent_hoover
8251ca2ebd72   ghost     "docker-entrypoint.s…"   3 hours ago  Up 3 hours    2368/tcp    jolly_varahamihira
```

> 输出详情介绍：
> 
> **CONTAINER ID:** 容器 ID。
> 
> **IMAGE:** 使用的镜像。
> 
> **COMMAND:** 启动容器时运行的命令。
> 
> **CREATED:** 容器的创建时间。
> 
> **STATUS:** 容器状态。
> 
> **PORTS:** 容器的端口信息和使用的连接类型（tcp\udp）。
> 
> **NAMES:** 容器名称。

```bash
# 列出最近创建的5个容器
$ docker ps -n 5
```

### top

> 查看容器中运行的进程

```bash
$ docker top 908d
UID            PID            PPID            C            STIME            TTY            TIME            CMD
dragon         7493          7468            0            Mar11            ?      00:00:06     node current/index.js
```

### logs

> 查看日志

  **语法**

```bash
$ docker logs [OPTIONS] CONTAINER
```

> OPTIONS说明：
> 
> - **-f :** 跟踪日志输出
> - **--since :**显示某个开始时间的所有日志
> - **-t :** 显示时间戳
> - **--tail :**仅列出最新N条容器日志

  **实例**

```bash
$ docker logs e87b --tail 10
[2020-03-11 09:47:33] INFO Model: User
[2020-03-11 09:47:36] INFO Model: Post
[2020-03-11 09:47:36] INFO Model: Integration
[2020-03-11 09:47:36] INFO Relation: Role to Permission
[2020-03-11 09:47:36] INFO Relation: Post to Tag
[2020-03-11 09:47:37] INFO Relation: User to Role
[2020-03-11 09:47:39] INFO Ghost is running in production...
[2020-03-11 09:47:39] INFO Your site is now available on http://localhost:2368/
[2020-03-11 09:47:39] INFO Ctrl+C to shut down
[2020-03-11 09:47:39] INFO Ghost boot 9.19s

$ docker logs --since="2020-03-11" --tail=10 myghost
```

### attach

```bash
$ docker run -dit ubuntu
$ docker ps

$ docker attach ${ubuntu-id}
```

> 使用这个命令退出后，会导致容器的停止，所以我们一般不用这个命令

### exec

> 配合 -i -t 参数使用

```bash
  $ docker exec -it {container} /bin/bash
```

### 导入导出

```bash
$ docker ps
CONTAINER ID    IMAGE        COMMAND            CREATED      STATUS            PORTS              NAMES
c03cc0150ec0    centos        "/bin/bash"               11 hours ago       Up 11 hours                competent_faraday
908dae191777   ghost:v3   "docker-entrypoint.s…"   14 hours ago   Up 14 hours   2368/tcp   condescendi_serland
e87b3c175433   ghost:v2   "docker-entrypoint.s…"   14 hours ago   Up 14 hours   2368/tcp   eloquent_hoover
8251ca2ebd72   ghost     "docker-entrypoint.s…"   14 hours ago   Up 14 hours   2368/tcp   jolly_varahamihira
$ docker export c03c >  centos.tar
$ ls
centos.tar  test
$ docker import centos.tar runoob/centos:v1
sha256:b5617da775a7029cbd39751a78648f38a6c4ea814d63afb964bc5d2ffe2d1b5e
$ docker images
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
runoob/centos               v1                  b5617da775a7        8 seconds ago       237MB
ghost               v5                  99199520ec4e        14 hours ago        394MB
ghost               v4                  7d768396433e        14 hours ago        394MB
ghost               v2                  051c57821d49        14 hours ago        394MB
ghost               v3                  051c57821d49        14 hours ago        394MB
ghost               latest              d37060d26de6        2 days ago          394MB
nginx               latest              6678c7c2e56c        7 days ago          127MB
ubuntu              latest              72300a873c2c        2 weeks ago         64.2MB
centos              latest              470671670cac        7 weeks ago         237MB
hello-world           latest              fce289e99eb9        14 months ago       1.84kB
```

### commit

> **docker commit :**从容器创建一个新的镜像。

 **语法**

```bash
$ docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]   
```

> OPTIONS说明：
> 
> - **-a :**提交的镜像作者
> - **-c :**使用Dockerfile指令来创建镜像
> - **-m :**提交时的说明文字
> - **-p :**在commit时，将容器暂停

**实例**

```bash
$ docker commit -a "noob" -m "I'm a noob." 8251 noob/ghost:v1
```

### cp

> **docker cp :**用于容器与主机之间的数据拷贝。

**语法**

```bash
$ docker cp [OPTIONS] SRC_PATH DEST_PATH
```

**实例**

```bash
# 容器里有noob 目录,test 就会拷贝到 noob 里面
$ docker cp ./test c03c:/home/noob

# 容器里没有 docker 目录,就会把 test 重命名为docker
$ docker cp ./test c03c:/home/docker
```

## 3 镜像仓库

### login

> **docker login :** 登陆到一个Docker镜像仓库，如果未指定镜像仓库地址，默认为官方仓库 Docker Hub
> 
> **docker logout :** 登出一个Docker镜像仓库，如果未指定镜像仓库地址，默认为官方仓库 Docker Hub

**实例**

```bash
$ docker login -u user -p **** repository.anxinyun.cn
```

### pull

```bash
$ docker pull [OPTIONS] NAME[:TAG|@DIGEST]

$ docker pull node
```

### push

> **docker push :** 将本地的镜像上传到镜像仓库,要先登陆到镜像仓库

```bash
$ docker push repository.anxinyun.cn/anxinyun/console:dragon.226
```

### search

> **docker search :** 从Docker Hub查找镜像

**语法**

```bash
$ docker search [OPTIONS] TERM
```

> OPTIONS说明：
> 
> - --filter
> - --limit

**实例**

```bash
# 只列出 automated build类型的镜像
$ docker search --filter is-automated=true java

$ docker search --filter is-automated=true --filter stars=30 java
```

## 4 本地镜像管理

### images

> **docker images :** 列出本地镜像。

**语法**

```bash
$ docker images [OPTIONS] [REPOSITORY[:TAG]]
```

> OPTIONS说明：
> 
> - **-a :**列出本地所有的镜像（含中间映像层，默认情况下，过滤掉中间映像层）；
> - **--digests :**显示镜像的摘要信息；
> - **-f :**显示满足条件的镜像；
> - **--format :**指定返回值的模板文件；
> - **--no-trunc :**显示完整的镜像信息；
> - **-q :**只显示镜像ID。

**实例**

```bash
$ docker images

$ docker images  ubuntu
```

### rmi

> **docker rmi :** 删除本地一个或多少镜像。

```bash
$ docker rmi -f ubuntu
```

### tag

```bash
docker tag [OPTIONS] IMAGE[:TAG] [REGISTRYHOST/][USERNAME/]NAME[:TAG]
```

```bash
$ docker tag ghost noob/ghost:v1
```

### build

> **docker build** 命令用于使用 Dockerfile 创建镜像。

**语法**

```bash
docker build [OPTIONS] PATH | URL | -
```

> OPTIONS说明：
> 
> - **-f :**指定要使用的Dockerfile路径；
> - **--pull :**尝试去更新镜像的新版本；
> - **--quiet, -q :**安静模式，成功后只输出镜像 ID；
> - **--rm :**设置镜像成功后删除中间容器；
> - **--tag, -t:** 镜像的名字及标签，通常 name:tag 或者 name 格式；可以在一次构建中为一个镜像设置多个标签。

**实例**

```bash
 $ docker build -t repository.anxinyun.cn/anxinyun/console:dragon.226 --pull=true .
```

## 5 info|version

### info

> docker info : 显示 Docker 系统信息，包括镜像和容器数

```bash
$ docker info
```

### version

> docker version :显示 Docker 版本信息

```bash
$ docker version
```
