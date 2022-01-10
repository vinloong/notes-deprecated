

`pv` : 是对底层存储的抽象，将存储定义为一种“资源”



`pvc`: 客户端对存储资源的一个“申请”



`storageclass`： 对存储类型的抽象定义，用于标记存储资源的特性和性能， localhost、nfs 、ceph 。。。



# 持久化



## 静态供应

`pv` 是管理员创建的。



```yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: localhost-pv
  labels:
    type: local
spec:
  storageClassName: localhostpath
  capacity:
    storage: 15Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/home/dragon/storage"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: localhostpath-pvc
  namespace: dragon
spec:
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi
  storageClassName: localhostpath
```



`pv ` 关键的配置

- **1、存储能力（Capacity）** 
- **2、存储卷模式（Volume Mode）**
- **3、访问模式（Access Modes）**
- **4、存储类别（Class）**
- **5、回收策略（Reclaim Policy）**



### 访问模式：

◎ ReadWriteOnce（RWO）：读写权限，并且只能被单个Node挂载。

◎ ReadOnlyMany（ROX）：只读权限，允许被多个Node挂载。

◎ ReadWriteMany（RWX）：读写权限，允许被多个Node挂载。



### 回收策略

通过 __persistentVolumeReclaimPolicy__ 字段设置，

◎ Retain 保留：保留数据，需要手工处理。

◎ Recycle 回收空间：简单清除文件的操作（例如执行rm -rf /thevolume/* 命令）。

◎ Delete 删除：与PV相连的后端存储完成Volume的删除操作



## 动态供应

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: localhostpath
  namespace: dragon
spec:
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 8Gi
  storageClassName: localhostpath
```





## 使用

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: my-app
spec:
  containers:
    - name: my-frontend
      image: busybox
      volumeMounts:
      - mountPath: "/scratch"
        name: scratch-volume
      command: [ "sleep", "1000000" ]
  volumes:
    - name: scratch-volume
      persistentVolumeClaim:
        claimName: localhostpath

```



# Secret



## TLS

```shell
kubectl create secret tls ${secret_name} --namespace=${namespace} --key=${key} --cert=${cert}
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret-tls
  namespace: dragon
type: kubernetes.io/tls
data:
  tls.crt: |
    <base64 encoded  >
  tls.key: |
    <base64 encoded  >

```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret-tls
  namespace: dragon
type: kubernetes.io/tls
stringData:
  tls.crt: |
    "<raw string>"
  tls.key: |
    "<raw string>"
```

### 使用

```yaml
kind: Ingress
apiVersion: extensions/v1beta1
metadata:
  name: web-console
  namespace: anxincloud
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/proxy-body-size: 50m
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.org/redirect-to-https: 'true'
spec:
  tls:
    - hosts:
        - console.anxinyun.cn
      secretName: anxincloud-root-secret
  rules:
    - host: console.anxinyun.cn
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              serviceName: web-console
              servicePort: 9083
```



## dockerconfigjson

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret-dockercfg
type: kubernetes.io/dockercfg
data:
  .dockercfg: |
        "<base64 encoded ~/.dockercfg file>"
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret-dockercfg
type: kubernetes.io/dockercfg
stringData:
  .dockercfg: |
    {
      "auths": {
              "https://registry.cn-hangzhou.aliyuncs.com": {
              "username": "hi50040201@aliyun.com",
              "password": "V9rtCnt$f",
              "email": "huang.li@free-sun.com.cn",
              "auth": "aGk1MDA0MDIwMUBhbGl5dW4uY29tOlY5cnRDbnQkZg=="
          }
      }
    }

```

## 使用

```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: api-anxincloud
  namespace: anxincloud
  labels:
    app: api-anxincloud
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-anxincloud
  template:
    metadata:
      labels:
        app: api-anxincloud
    spec:
      containers:
        - name: api-anxincloud
          image: >-
            registry.cn-hangzhou.aliyuncs.com/fs-cloud/anxinyun-web.api:179.21-12-15
          command:
            - node
            - server.js
          ports:
            - name: http-8080
              containerPort: 8080
              protocol: TCP
          envFrom:
            - configMapRef:
                name: cm-anxincloud
          imagePullPolicy: IfNotPresent
      restartPolicy: Always
      nodeSelector:
        app.type: web
      imagePullSecrets:
        - name: registry-secret

```





# ConfigMap



