通过编写 Dockerfile,构建自己的 Docker 镜像，可以永久解决时区问题。

## 1. Alpine

```dockerfile
ENV TZ Asia/Shanghai

RUN apk add tzdata && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && apk del tzdata
```

## 2. Debian
Debian 基础镜像 中已经安装了 tzdata 包，我们可以将以下代码添加到 Dockerfile 中：
```dockerfile
ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive

RUN ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*
```

## 3. Ubuntu
Ubuntu 基础镜像中没有安装了 tzdata 包，因此我们需要先安装 tzdata 包。
我们可以将以下代码添加到 Dockerfile 中。

```dockerfile
ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive

RUN apt update \
    && apt install -y tzdata \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*
```

## 4. CentOS
CentOS 基础镜像 中已经安装了 tzdata 包，我们可以将以下代码添加到 Dockerfile 中。
```dockerfile
ENV TZ Asia/Shanghai

RUN ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone
```

