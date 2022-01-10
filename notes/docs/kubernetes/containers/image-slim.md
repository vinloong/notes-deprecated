# 给你的镜像瘦身

镜像构建时，我们希望是镜像在满足我们的服务需求的前提下，体积越小越好，那么应该怎么做呢？

## 镜像体积分析

Docker镜像是由很多镜像层（Layers）组成的（最多127层）， Dockerfile 中的每条指定都会创建镜像层，不过**只有 `RUN`, `COPY`, `ADD` 会使镜像的体积增加**。这个可以通过命令 `docker history image_id` 来查看每一层的大小。 这里我们以官方的 `alpine` 为例看看它的镜像层情况:

```shell
$ docker history alpine
IMAGE          CREATED       CREATED BY                                      SIZE      COMMENT
c059bfaa849c   6 weeks ago   /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B
<missing>      6 weeks ago   /bin/sh -c #(nop) ADD file:9233f6f2237d79659…   5.59MB
```

```dockerfile
FROM scratch
ADD alpine-minirootfs-3.15.0-x86_64.tar.gz /
CMD ["/bin/sh"]
```

对比 Dockerfile 和镜像历史层数发现 `ADD` 命令层占据了 5.57M 大小，而 `CMD` 命令层并不占空间。

镜像的层就像我们每一次提交 代码, 用于保存镜像的上一个版本和当前版本之间的差异。

所以当我们使用 `docker pull` 命令从公有或私有的 Hub 上拉取镜像时，它只会下载我们尚未拥有的层。

了解了镜像构建中体积增大的原因，那么就可以对症下药：**精简层数**或**精简每一层大小**

* 精简层数的方法有如下几种：
  * `RUN`指令合并
  * 多阶段构建
* 精简每一层的方法有如下几种:
  * 使用合适的基础镜像(首选alpine)
  * 删除`RUN`的缓存文件

## 瘦身

### RUN指令合并

指令合并是最简单也是最方便的降低镜像层数的方式。该操作节省空间的原理是在同一层中清理“缓存”和工具软件。

```bash
```



### 使用多阶段构建

多阶段构建方法是官方打包镜像的最佳实践，它是将精简层数做到极致的方法。

通俗点讲它是将打包镜像分成两个阶段：

- 一个阶段用于开发，打包，该阶段包含构建应用程序所需的所有内容；

- 一个用于生产运行，该阶段只包含你的应用程序以及运行它所需的内容。

这被称为“建造者模式”。使用多阶段构建肯定会降低镜像大小，但是瘦身的粒度和编程语言有关系，对编译型语言效果比较好，因为它去掉了编译环境中多余的依赖，直接使用编译后的二进制文件或jar包。而对于解释型语言效果就不那么明显了。

我们在 `jenkins` 容器中构建完将结果再拷贝到基础镜像中，也可以说是一种多阶段构建。

```dockerfile

```

### 选择合适的基础镜像

基础镜像，推荐使用 Alpine。

Alpine 是一个高度精简又包含了基本工具的轻量级 Linux 发行版，基础镜像只有 5.x M，各开发语言和框架都有基于 Alpine 制作的基础镜像，强烈推荐使用它。

进阶可以尝试使用scratch和busybox镜像进行基础镜像的构建。

 ```bash
 dragon@LWL-PC:~/images$ docker images | { head -1; grep node; }
 REPOSITORY          TAG                    IMAGE ID       CREATED         SIZE
 node                12                     fb17a1009e1c   8 days ago      918MB
 node                12-alpine              106bb94759ad   12 days ago     89.5MB
 ```

`node:12-alpine` 的镜像大小不到 `node:12` 的 1/10.

所以相同的构建使用 ``node:12-alpine` `肯定会小很多

> 使用 Alpine镜像有个注意点，就是它是基于 muslc的（glibc的替代标准库），这两个库实现了相同的内核接口。 其中 glibc 更常见，速度更快，而 muslic 使用较少的空间，侧重于安全性。 在编译应用程序时，大部分都是针对特定的 libc 进行编译的。如果我们要将它们与另一个 libc 一起使用，则必须重新编译它们。换句话说，基于 Alpine 基础镜像构建容器可能会导致非预期的行为，因为标准 C 库是不一样的。

这里已经基于apline做了一个glibc 的镜像，[Dockerfile 地址](http://10.8.30.22/base-images/alpine-glibc)

### 删除RUN的缓存文件

linux中大部分包管理软件都需要更新源，该操作会带来一些缓存文件，这里记录了常用的清理方法:

- 基于 alpine 的镜像

  ```sh
  # 换国内源，并更新     
  sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories     
  # --no-cache 表示不缓存     
  apk add --no-cache a b c && rm -rf /var/cache/apk/*
  ```

- 基于 ubuntu/debian 的镜像

  ```bash
  # 换国内源，并更新     
  sed -i “s/deb.debian.org/mirrors.aliyun.com/g” /etc/apt/sources.list && apt update     
  # --no-install-recommends 很有用     
  apt install -y --no-install-recommends a b c && rm -rf /var/lib/apt/lists/*
  ```

- 基于 centos 的镜像

  ```bash
  # 换国内源并更新
  curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && yum makecache
  yum install -y a b c  && yum clean al
  ```



### 使用镜像瘦身工具

`docker-slim`

```
docker-slim build <target-image>
```

> 有副作用，瘦身后一定要检查下镜像是否可用



