

# 容器安装
[[../docker/docker volume]]
```shell

docker volume create --name fs-girlab-config --opt type=none --opt device=/data/girlab/config --opt o=bind

docker volume create --name fs-girlab-data --opt type=none --opt device=/data/girlab/data --opt o=bind

docker volume create --name fs-girlab-log --opt type=none --opt device=/data/girlab/log --opt o=bind

docker volume create --name fs-girlab-redis --opt type=none --opt device=/data/redis/data --opt o=bind

docker run -d -p 18086:8181 -p 1022:22 \
           --hostname "gitlab.free-sun.vip" \
           -e "GITLAB_SHELL_SSH_PORT=1022" \
           --name fs-gitlab \
           --restart always \
           --net=net-gitlab \
           -v fs-gitlab-config:/etc/gitlab  \
           -v fs-gitlab-log:/var/log/gitlab \
           -v fs-gitlab-data:/var/opt/gitlab \
           gitlab/gitlab-ce:latest


docker run -d \ 
           -v fs-girlab-redis:/data \
		   -p 6379:6379 \
		   --net=net-gitlab \
		   --name fs-gitlab-redis \
		   redis:6-alpine

```

配置文件

```shell
vi /etc/gitlab/gitlab.rb
```

# 配置优化
## 配置使用外部 pg
[[postgres]]
```sql
-- 创建一个有创建数据库的权限的角色
CREATE ROLE gitlab WITH LOGIN PASSWORD 'mypassword!' SUPERUSER;

-- 创建数据库(没有数据库会提示初始化数据库失败)
create database "fsgitlab" owner "gitlab";

GRANT ALL PRIVILEGES ON DATABASE fsgitlab TO gitlab;
```

```ini
postgresql['enable'] = false 
gitlab_rails['db_adapter'] = "postgresql" 
gitlab_rails['db_encoding'] = "utf8" 
gitlab_rails['db_database'] = "fsgitlab" 
gitlab_rails['db_username'] = "gitlab" 
gitlab_rails['db_password'] = "mypassword" 
gitlab_rails['db_host'] = "10.8.40.223" 
gitlab_rails['db_port'] = 5432
```


## 配置使用外部redis

```ini
# 禁用内部 redis
redis['enable'] = false

gitlab_rails['redis_host'] = "10.8.40.122"
gitlab_rails['redis_port'] = 6379
gitlab_rails['redis_database'] = 0
```


## 配置禁用内部nginx

```ini
nginx['enable'] = false 
gitlab_workhorse['listen_network'] = "tcp" 
gitlab_workhorse['listen_addr'] = "0.0.0.0:8181"
```


## 禁用其他服务

```ini

# 禁用容器仓库服务
gitlab_rails['registry_enabled'] = false
registry['enable'] = false

# 禁用 k8s 代理服务
gitlab_kas['enable'] = false

# 禁用 prometheus 
prometheus['enable'] = false

# 禁用 grafana
grafana['enable'] = false

```




## 配置邮箱
```ini
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.exmail.qq.com"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "anxinyunwarning@free-sun.com.cn"
gitlab_rails['smtp_password'] = "SGVd7FU7vesjj9su"
gitlab_rails['smtp_domain'] = "smtp.exmail.qq.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = true


gitlab_rails['gitlab_email_enabled'] = true

gitlab_rails['gitlab_email_from'] = 'anxinyunwarning@free-sun.com.cn'
gitlab_rails['gitlab_email_display_name'] = 'fs-gitlab'

```

## 遇到的问题
> 域名设置好后，在仓库克隆的下面得不到你要的 url ?
 `ssh://5e89fe76963a:it/it-archived.git`
 > 这个地址明显不对，你查一些解决方式很多都是要你设置 `external_url`，
 > 改成 域名、ip、ip +  端口,
 > 这些方案都是错的，都没有用。 
> 它默认是你的`hostname` , 我们设置了这个参数后，他会用这个参数替换hostname.
> 然而他是无法解析这个地址的，
> 后来我把容器的`hostname`直接设置成我们的域名，`--hostname "gitlab.free-sun.vip" ` 解决。
> 这样 内部解析和我们外网用的域名一致，都能解析到相应的地址

# k8s ingress 代理

`endpoints.yaml` :
```yaml
apiVersion: v1
kind: Endpoints
metadata:
  name: fs-gitlab
  namespace: ops
subsets:
  - addresses:
      - ip: 10.8.40.122
    ports:
      - port: 18086
        name: web
```

`service.yaml` :
```yaml
apiVersion: v1
kind: Service
metadata:
  name: fs-gitlab
  namespace: ops
spec:
  type: ClusterIP
  ports:
    - protocol: TCP
      name: web
      port: 18086
      targetPort: 18086

```

`ingress.yaml`:
```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-fs-gitlab
  namespace: ops
  annotations:
        kubernetes.io/ingress.class: "nginx"
        nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: gitlab.free-sun.vip
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          serviceName: fs-gitlab
          servicePort: 18086
                        

```

# 常用命令

```shell

# 重新读取配置
gitlab-ctl reconfigure

# 重启服务
gitlab-ctl restart


```