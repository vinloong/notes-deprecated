---
title: 利用阿里云构建自己的镜像
author: Uncle Dragon
date: 2021-07-23
categories: k8s&container
tags: [container]
---

<div align='center' ><b><font size='70'> 利用阿里云构建自己的镜像 </font></b></div>























<center> author: Uncle Dragon </center>


<center>   date: 2021-07-23 </center>


<div STYLE="page-break-after: always;"></div>




国内网络环境原因，经常遇到无法拉取的镜像或者镜像拉取特别慢，那么如何自己构建镜像呢，最近试用了阿里云的[容器镜像服务](https://cr.console.aliyun.com/cn-hangzhou/instances) ,还可以。

我用的个人版。个人版命名空间3个，仓库可以300个，够用了。



 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191050069.png)



进入后可以看到使用情况

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191050197.png)



创建命名空间



 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191050373.png)

创建镜像仓库：



 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191050881.png)



下一步，选择代码源：

这里我选择的github,首次使用需要授权：



 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191051542.png)



选择代码仓库，我这里是 google_containers[^1],这个仓库里写了一些Dockerfile ,下面构建设置选择海外机器构建，

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191051064.png)

下面点创建镜像仓库，成功后选择构建，我们设置下构建：

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191052643.png)



设置下Dockerfile 目录，

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191052725.png)



 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191052805.png)



点`立即构建`

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191052487.png)

构建成功后：

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191053170.png)



我们使用的时候就拉取指定版本的镜像就可以了



```shell
# $ docker pull registry.cn-hangzhou.aliyuncs.com/gcr_k8s_containers/kube-scheduler:[镜像版本号]
# 比如
$ docker pull registry.cn-hangzhou.aliyuncs.com/gcr_k8s_containers/kube-scheduler:v1.18.2
```




[^1]: [google containers](https://github.com/uncle-dragon/google_containers)