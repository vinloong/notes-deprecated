

#  设置`storageClass`

> 由于 部署 是使用的 microk8s 并且这个小集群只有一台服务器，所以存储就保存到本地

`storageClass.yaml`

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "false"
  name: microk8s-localhost
provisioner: microk8s.io/hostpath
reclaimPolicy: Retain
volumeBindingMode: Immediate
```

```bash
$ kubectl apply -f storageClass.yaml


$ kubectl get sc 
NAME                          PROVISIONER            RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
microk8s-hostpath (default)   microk8s.io/hostpath   Delete          Immediate           false                  4d4h
microk8s-localhost            microk8s.io/hostpath   Retain          Immediate           false                  3d1h
```



# 部署数据库



## 设置 pvc

`pg-pvc.yaml`

```yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: postgres-data-pv
  labels:
    type: local
    app: postgres-data
spec:
  storageClassName: microk8s-localhost
  capacity:
    storage: 15Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/var/local/postgresql/data"
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: postgres-data-pvc
  namespace: devops
  labels:
    app: postgres-data
spec:
  storageClassName: microk8s-localhost
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi

```

```bash
$ kubectl apply -f pg-pvc.yaml

$ kubectl get pv 
NAME               CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                      STORAGECLASS         REASON   AGE
postgres-data-pv   15Gi       RWX            Retain           Bound    devops/postgres-data-pvc   microk8s-localhost            3d

$ kubectl get pvc -n devops
NAME                STATUS   VOLUME             CAPACITY   ACCESS MODES   STORAGECLASS         AGE
postgres-data-pvc   Bound    postgres-data-pv   15Gi       RWX            microk8s-localhost   3d

```



`configmap.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cm-postgres
  namespace: devops
  labels:
    app: postgres
data:
  POSTGRES_PASSWORD: postgres
```

```shell
$ kubectl apply -f configmap.yaml

$ kubectl get cm -n devops
NAME               DATA   AGE
kube-root-ca.crt   1      3d5h
cm-postgres        1      2d2h

```

`deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gitea-postgres
  namespace: devops
spec:
  selector:
    matchLabels:
      app: postgres
  replicas: 1
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: gitea-postgres
          image: postgres:12-alpine
          ports:
            - containerPort: 5432
              name: pg-port
          envFrom:
            - configMapRef:
                name: cm-postgres
          volumeMounts:
            - mountPath: /var/lib/postgresql/data
              name: postgres-data-volume
      volumes:
        - name: postgres-data-volume
          persistentVolumeClaim:
            claimName: postgres-data-pvc
```

```bash
$ kubectl apply -f deployment.yaml

$ kubectl get po -n devops
NAME                              READY   STATUS    RESTARTS   AGE
gitea-postgres-86d6b8c4c7-rbt45   1/1     Running   0          2d1h

```

`service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: devops
  labels:
    app: postgres
spec:
  type: NodePort
  ports:
  - port: 5432
    targetPort: 5432
    protocol: TCP
    name: pg-port
    nodePort: 30432
  selector:
   app: postgres
```

```shell
$ kubectl apply -f service.yaml


$ kubectl get svc -n devops
NAME               TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)                       AGE
postgres-service   NodePort   10.152.183.142   <none>        5432:30432/TCP                2d1h

```



### 配置

`postgresql.conf`

```properties

# 时区修改
log_timezone = 'Asia/Shanghai'
timezone = 'Asia/Shanghai'


# 密码加密算法修改
password_encryption = scram-sha-256
```



`pg_hba.conf`

```properties
# 本地访问
local   giteadb         gitea                                   scram-sha-256

# 远程访问
host    giteadb         gitea           0.0.0.0/0               scram-sha-256
```



重启数据库



```sql
# 创建用户和数据库

CREATE ROLE gitea WITH LOGIN PASSWORD 'gitea';

CREATE DATABASE giteadb WITH OWNER gitea TEMPLATE template0 ENCODING UTF8 LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8';

```



# 部署 `Gitea`

`gitea-pvc.yaml`

```yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: gitea-data-pv
  labels:
    type: local
    app: gitea
spec:
  storageClassName: microk8s-localhost
  capacity:
    storage: 500Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/var/local/gitea/data"
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: gitea-data-pvc
  namespace: devops
  labels:
    app: gitea
spec:
  storageClassName: microk8s-localhost
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 200Gi
```



```shell
$ kubectl apply -f gitea-pvc.yaml

$ kubectl get pv 
NAME               CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                      STORAGECLASS         REASON   AGE
postgres-data-pv   15Gi       RWX            Retain           Bound    devops/postgres-data-pvc   microk8s-localhost            3d
gitea-data-pv      500Gi      RWX            Retain           Bound    devops/gitea-data-pvc      microk8s-localhost            47h
$ kubectl get pvc -n devops
NAME                STATUS   VOLUME             CAPACITY   ACCESS MODES   STORAGECLASS         AGE
postgres-data-pvc   Bound    postgres-data-pv   15Gi       RWX            microk8s-localhost   3d
gitea-data-pvc      Bound    gitea-data-pv      500Gi      RWX            microk8s-localhost   47h

```



`configmap.yaml`

```yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: cm-gitea
  namespace: devops
  labels:
    app: gitea
data:
  DB_TYPE: "postgres"
  DB_HOST: "postgres-service:5432"
  DB_NAME: "giteadb"
  DB_USER: "gitea"
  DB_PASSWD: "gitea"

```

```shell
$ kubectl apply -f configmap.yaml

$ kubectl get cm -n devops
NAME               DATA   AGE
kube-root-ca.crt   1      3d5h
cm-postgres        1      2d2h
cm-gitea           6      29h

```

`deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gitea
  namespace: devops
spec:
  selector:
    matchLabels:
      app: gitea
  replicas: 1
  template:
    metadata:
      labels:
        app: gitea
    spec:
      containers:
        - name: gitea
          image: gitea/gitea:1.14.6
          ports:
            - containerPort: 22
              name: ssh
            - containerPort: 3000
              name: http-port
          envFrom:
            - configMapRef:
                name: cm-gitea
          volumeMounts:
            - mountPath: /data
              name: gitea-data-volume
      volumes:
        - name: gitea-data-volume
          persistentVolumeClaim:
            claimName: gitea-data-pvc

```

```shell
$ kubectl apply -f deployment.yaml

$ kubectl get po -n devops
NAME                              READY   STATUS    RESTARTS   AGE
gitea-postgres-86d6b8c4c7-rbt45   1/1     Running   0          2d1h
gitea-c4b69d788-mdm7g             1/1     Running   0          6h10m

```

`service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: gitea-service
  namespace: devops
  labels:
    app: gitea
spec:
  type: NodePort
  ports:
  - port: 22
    targetPort: 22
    protocol: TCP
    name: ssh
    nodePort: 30022
  - port: 3000
    targetPort: 3000
    protocol: TCP
    name: http-port
    nodePort: 30300
  selector:
   app: gitea
```

```shell
$ kubectl apply -f service.yaml

$ kubectl get svc -n devops
NAME               TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)                       AGE
postgres-service   NodePort   10.152.183.142   <none>        5432:30432/TCP                2d1h
gitea-service      NodePort   10.152.183.62    <none>        22:30022/TCP,3000:30300/TCP   29h
```



配置

```ini
[server]
APP_DATA_PATH    = /data/gitea
DOMAIN           = gitea.free-sun.vip
SSH_DOMAIN       = gitea.free-sun.vip
HTTP_PORT        = 3000
ROOT_URL         = https://gitea.free-sun.vip/
DISABLE_SSH      = false
SSH_PORT         = 2022
SSH_LISTEN_PORT  = 22
LFS_START_SERVER = false
LFS_CONTENT_PATH = /data/git/lfs
LFS_JWT_SECRET   = ET6zJ0fRBl93bJiHrUAzOXa7xeicpEmY9weiyqwWQqI
OFFLINE_MODE     = false
LANDING_PAGE     = explore


[mailer]
ENABLED        = true
FROM           = anxinyunwarning@free-sun.com.cn
MAILER_TYPE    = smtp
HOST           = smtp.exmail.qq.com:465
IS_TLS_ENABLED = true
USER           = anxinyunwarning@free-sun.com.cn
PASSWD         = `SGVd7FU7vesjj9su`

```



nginx 配置

```properties
# http 增加 server 

upstream  gitea-http {
    server 192.168.0.121:30300;
}


server {
    listen 80;
    server_name  gitea.free-sun.vip;
    rewrite ^(.*) https://$server_name$1 permanent;
}


server {
    listen 443 ssl;
    server_name  gitea.free-sun.vip;
    client_max_body_size 5m;

    ssl_certificate   /etc/nginx/certs/gitea.free-sun.pem;
    ssl_certificate_key  /etc/nginx/certs/gitea.free-sun.key;
    ssl_session_timeout 5m;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;

    location / {
        client_max_body_size 20m;
        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://gitea-http;
        index index.html index.htm;
    }
}

```



```properties
# stream  增加 server  做 ssh 访问
upstream gitea_backend {
    hash $remote_addr consistent;
    server 192.168.0.121:30022 max_fails=3 fail_timeout=30s;
}

server {
    listen 2022 so_keepalive=on;
    tcp_nodelay    on;
    proxy_pass     gitea_backend;
    proxy_connect_timeout       20s;
    proxy_timeout        30m;
    proxy_buffer_size    32k;
}
```

















