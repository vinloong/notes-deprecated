# 简介 
## frp 是什么？

frp 是一个专注于内网穿透的高性能的反向代理应用，支持 TCP、UDP、HTTP、HTTPS 等多种协议。可以将内网服务以安全、便捷的方式通过具有公网 IP 节点的中转暴露到公网。

## 为什么使用 frp？

通过在具有公网 IP 的节点上部署 frp 服务端，可以轻松地将内网服务穿透到公网，同时提供诸多专业的功能特性，这包括：

- 客户端服务端通信支持 TCP、KCP 以及 Websocket 等多种协议。
- 采用 TCP 连接流式复用，在单个连接间承载更多请求，节省连接建立时间。
- 代理组间的负载均衡。
- 端口复用，多个服务通过同一个服务端端口暴露。
- 多个原生支持的客户端插件（静态文件查看，HTTP、SOCK5 代理等），便于独立使用 frp 客户端完成某些工作。
- 高度扩展性的服务端插件系统，方便结合自身需求进行功能扩展。
- 服务端和客户端 UI 页面。



# 概念

## 原理[ ](https://gofrp.org/docs/concepts/#原理)

frp 主要由 **客户端(frpc)** 和 **服务端(frps)** 组成，服务端通常部署在具有公网 IP 的机器上，客户端通常部署在需要穿透的内网服务所在的机器上。

内网服务由于没有公网 IP，不能被非局域网内的其他用户访问。

用户通过访问服务端的 frps，由 frp 负责根据请求的端口或其他信息将请求路由到对应的内网机器，从而实现通信。

## 代理

在 frp 中一个代理对应一个需要暴露的内网服务。一个客户端支持同时配置多个代理。

## 代理类型[ ](https://gofrp.org/docs/concepts/#代理类型)

frp 支持多种代理类型来适配不同的使用场景。

| 类型   | 描述                                                         |
| :----- | :----------------------------------------------------------- |
| tcp    | 单纯的 TCP 端口映射，服务端会根据不同的端口路由到不同的内网服务。 |
| udp    | 单纯的 UDP 端口映射，服务端会根据不同的端口路由到不同的内网服务。 |
| http   | 针对 HTTP 应用定制了一些额外的功能，例如修改 Host Header，增加鉴权。 |
| https  | 针对 HTTPS 应用定制了一些额外的功能。                        |
| stcp   | 安全的 TCP 内网代理，需要在被访问者和访问者的机器上都部署 frpc，不需要在服务端暴露端口。 |
| sudp   | 安全的 UDP 内网代理，需要在被访问者和访问者的机器上都部署 frpc，不需要在服务端暴露端口。 |
| xtcp   | 点对点内网穿透代理，功能同 stcp，但是流量不需要经过服务器中转。 |
| tcpmux | 支持服务端 TCP 端口的多路复用，通过同一个端口访问不同的内网服务。 |

# 安装

裸机安装很简单，这里就不详细介绍了：

```shell
# 下载好二进制文件解压

# 启动服务端
./frps -c ./frps.ini

# 启动客户端
./frpc -c ./frpc.ini
```

下面详细说下容器安装 … …

## 容器方式

STCP 和 SUDP 的 (S) 的含义是 Secret。其作用是为 TCP 和 UDP 类型的服务提供一种安全访问的能力，避免让端口直接暴露在公网上导致任何人都能访问到。

frp 会在访问端监听一个端口和服务端的端口做映射。访问端的用户需要提供相同的密钥才能连接成功，从而保证安全性。

结合我们的使用场景，不希望暴露太多的端口，所以选择 `stcp` 类型

根据`stcp` 的工作特点可知有三个进程，2个客户端，一个服务端：

> 一个客户端运行在被访问的内网主机上
>
> 访问端的客户端运行在可以连上服务端的任意地方

### 服务端镜像

`Dockerfile` :

```dockerfile
FROM repository.anxinyun.cn/devops/alpine:3.15-hw

ADD frp.tar.gz /

RUN apk add --no-cache tzdata; \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    echo "Asia/Shanghai" > /etc/timezone; \
    apk del tzdata

WORKDIR /frp

COPY entrypoint.sh .

EXPOSE 7000 7500

CMD ["./entrypoint.sh"]
```

配置文件：

```ini
[common]
# 服务端绑定的端口
bind_port = 7000
# 服务端 dashboard 端口
dashboard_port = 7500
dashboard_user = admin
dashboard_pwd = admin
```

### 被访问客户端

`Dockerfile`:

```dockerfile
FROM repository.anxinyun.cn/devops/alpine:3.15-a

ADD frp.tar.gz /

RUN apk add --no-cache tzdata; \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    echo "Asia/Shanghai" > /etc/timezone; \
    apk del tzdata

WORKDIR /frp

COPY entrypoint.sh .

CMD ["./entrypoint.sh"]

```

配置文件：

`frpc.ini`

```ini
[common]
# 服务端IP 端口
server_addr = xxx.xxx.xxx.xxx
server_port = 7000

# 客户端服务名，必须唯一
[secret_ssh]
type = stcp
# 只有 sk 一致的用户才能访问到此服务
sk = abcdefg
local_ip = 127.0.0.1
local_port = 22

```

### 访问端

`Dockerfile`:

```dockerfile
FROM repository.anxinyun.cn/devops/alpine:3.15-hw

ADD frp.tar.gz /

RUN apk add --no-cache tzdata openssh-client-common openssh-client-default; \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    echo "Asia/Shanghai" > /etc/timezone; \
    apk del tzdata

WORKDIR /frp

COPY entrypoint.sh .

CMD ["./entrypoint.sh"]

```

`frpc.ini`：

```ini
[common]
# 服务端IP 端口
server_addr = xxx.xxx.xxx.xxx
server_port = 7000

[secret_ssh_visitor]
type = stcp
role = visitor
# 必须与被访问端服务名一致
server_name = secret_ssh
# 必须与被访问端sk一致
sk = abcdefg
bind_addr = 127.0.0.1
bind_port = 6000

```























