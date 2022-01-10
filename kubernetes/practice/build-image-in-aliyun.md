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



 ![](http://resources.lingwenlong.com/note-img/20210803094350.png)



进入后可以看到使用情况

 ![](http://resources.lingwenlong.com/note-img/20210803094308.png)



创建命名空间



 ![](http://resources.lingwenlong.com/note-img/20210803094524.png)

创建镜像仓库：



 ![](http://resources.lingwenlong.com/note-img/20210803094743.png)



下一步，选择代码源：

这里我选择的github,首次使用需要授权：



 ![](http://resources.lingwenlong.com/note-img/20210803094841.png)



选择代码仓库，我这里是 google_containers[^1],这个仓库里写了一些Dockerfile ,下面构建设置选择海外机器构建，

 ![](http://resources.lingwenlong.com/note-img/20210803094954.png)

下面点创建镜像仓库，成功后选择构建，我们设置下构建：

 ![](http://resources.lingwenlong.com/note-img/20210803095220.png)



设置下Dockerfile 目录，

 ![](http://resources.lingwenlong.com/note-img/20210803095406.png)



 ![](http://resources.lingwenlong.com/note-img/20210803095453.png)



点`立即构建`

![](http://resources.lingwenlong.com/note-img/20210803095607.png)

构建成功后：

 ![](http://resources.lingwenlong.com/note-img/20210803095626.png)



我们使用的时候就拉取指定版本的镜像就可以了



```shell
# $ docker pull registry.cn-hangzhou.aliyuncs.com/gcr_k8s_containers/kube-scheduler:[镜像版本号]
# 比如
$ docker pull registry.cn-hangzhou.aliyuncs.com/gcr_k8s_containers/kube-scheduler:v1.18.2
```




[^1]: [google containers](https://github.com/uncle-dragon/google_containers)