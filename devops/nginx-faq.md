# nginx 



## 背景

前几天别人把非法域名解析我们IP 了，电信找我们让我们自己处理 。。。 。。。

## 限制IP访问

 `defalult server` 做如下配置：

```properties
server {
        listen 80 default_server;
        server_name _;
        return 403;
}
```

上面配置可以限制 ip 访问 80 端口。

但是 `https:ip:443` 还是可以访问, 所以在域名解析下再增加如下配置：

```properties
server {
    listen 443 ssl;
    server_name  <your-domain>;
    if ($host != $server_name) {
        return 403;
    }
}

```



经过上面配置，在使用IP就无法访问80和443端口了。

