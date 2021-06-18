# 无法连接网络
```shell
# 1. 查看网关
route -n

# 设置默认网关
route add default gw 10.8.30.1

# 2. 以上不行执行下面命令
dhclient eno1
```



# 软件安装卸载总是报错

> dpkg: 处理软件包 redis-server (--configure)时出错： 子进程 已安装 post-installation 脚本 返回错误状态 1

```shell
sudo rm /var/lib/dpkg/info/redis-server.*
```

