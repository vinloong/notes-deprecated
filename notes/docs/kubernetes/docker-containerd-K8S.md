话说前一段时间，各个自媒体都在说`k8s` 要弃用`docker`了。以至于有些朋友同事问我，是不是真的，`docker`都还没学就过时了。其实 `k8s `弃用的是 `Dockershim` ,什么是 `Dockershim` ，这就得简单说下：`Kubernetes`、`Docker`、`Containerd`三者之间的关系了。
# `Docker`、`OCI` 和 `Containerd`
这里略过早期`Docker`的发展历史，大概就是在`docker`如日中天的时候，社区要搞容器化标准，成立了`OCI`(Open Container Initiaiv)，`OCI`主要包含两个规范，一个是容器运行时规范(runtime-spec)，一个是容器镜像规范(image-spec)。`docker`的公司也在`OCI`中，这里略过在推动标准化过程中各大厂各自心里的"小算盘"和"利益考虑"，`docker`在这个过程中由一个庞然大物逐渐拆分出了`containerd`、`runc`等项目，docker公司将`runc`捐赠给了 `OCI`，后来将`containerd`捐赠给了`CNCF`

-   `runc`是什么?`runc`是一个轻量级的命令行工具，可以用它来运行容器。`runc`遵循`OCI`标准来创建和运行容器，它算是第一个`OCI Runtime`标准的参考实现。
-   `containerd`是什么？`containerd`的自我介绍中说它是一个开放、可靠的容器运行时，实际上它包含了单机运行一个容器运行时的功能。

`containerd`为了支持多种`OCI Runtime`实现，内部使用`containerd-shim`，`shim`英文翻译过来是"垫片"的意思，见名知义了，例如为了支持`runc`，就提供了`containerd-shim-runc`。

经过上面的发展，docker启动一个容器的过程大致是下图所示的流程:
![](img/containerd-001.png)
从上图可以看出，每启动一个容器，实际上是`containerd`启动了一个`containerd-shim-runc`进程，即使`containerd`的挂掉也不会影响到已经启动的容器。

# `Kubernetes`,`Docker`和`Containerd`
`kubernetes`的出现是为了解决容器编排的问题，在早期为了支持多个容器引擎，是在`Kubernetes`内部对多个容器引擎做兼容，例如`kubelet`启动一个`docker-manager`的进程直接调用docker的api进行容器的创建