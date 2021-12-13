---
title: Dockerfile常用命令解析
date: 2020-04-11
categories: 
    - k8s&docker
tags: [docker]
---

## 什么是`Dockerfile`

> Dockerfile 是一个用来构建镜像的文本文件，文本内容包含了一条条构建镜像所需的指令和说明。

## 指令详解

### FROM
> 定制的镜像都是基于 FROM 的镜像。

<!--more-->

### RUN
> 用于执行后面跟着的命令行命令

**注意**：Dockerfile 的指令每执行一次都会在 docker 上新建一层。所以过多无意义的层，会造成镜像膨胀过大。例如：

```dockerfile
FROM centos
RUN yum install wget
RUN wget -O redis.tar.gz "http://download.redis.io/releases/redis-5.0.3.tar.gz"
RUN tar -xvf redis.tar.gz
# 以上执行会创建 3 层镜像。可简化为以下格式：
FROM centos
RUN yum install wget \
    && wget -O redis.tar.gz "http://download.redis.io/releases/redis-5.0.3.tar.gz" \
    && tar -xvf redis.tar.gz
```

如上，以 **&&** 符号连接命令，这样执行后，只会创建 1 层镜像。

### COPY

```dockerfile
COPY <源路径1>...  <目标路径>
```





### CMD



```dockerfile
shell 格式：CMD <命令>
exec 格式：CMD ["可执行文件", "参数1", "参数2"...]
```

可以被替换

```bash
$ docker run -it ubuntu cat /etc/os-release

# 替换了 [/bin/bash]

$ docker run -it ubuntu 
```

```dockerfile
CMD [ "sh", "-c", "echo $HOME" ]
```





### ENTRYPOINT

> 指定 ENTRYPOINT后，如果有 CMD ，则，CMD 不再是直接运行的命令，而是作为参数传给 ENTRYPOINT 使用



### ENV

```dockerfile
ENV <key> <value>
ENV <key1>=<value1> <key2>=<value2>...
```



### EXPOSE

```dockerfile
EXPOSE <端口1> [<端口2>...]
```



### WORKDIR

```dockerfile
WORKDIR <工作目录路径>
```



### USER

```dockerfile
USER <用户名>
```



## 定制一个镜像

> 定制一个镜像：jdk8 + python3 



```dockerfile
# 基础镜像 使用 alpine
FROM alpine
# 更换软件源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone 
RUN apk update && apk add openjdk8 python3 
```



