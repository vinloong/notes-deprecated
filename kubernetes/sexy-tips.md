# k8s 使用的一些技巧



## 在容器中获取pod 的IP

设置一个环境变量来引用 resource 的状态字段：

```yaml
kind: StatefulSet
apiVersion: apps/v1
metadata:
  name: redis-app
  namespace: ops
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
        - name: redis
          image: 'redis:5.0'
          command:
            - redis-server
          args:
            - /etc/redis/redis.conf
            - '--protected-mode'
            - 'no'
            - '--cluster-announce-ip'
            - $(POD_IP)
          ports:
            - name: redis
              containerPort: 6379
              protocol: TCP
          env:
            - name: POD_IP
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: status.podIP

```



## pod 使用外部DNS

修改 `coredns` 的使用的 `ConfigMap`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
          lameduck 5s
        }
        hosts {
          10.8.30.157  test-master
          10.8.30.152  test-n1
          10.8.30.156  test-n2
          10.8.30.155  test-n3
          10.8.30.161  test-n4
          10.8.30.141  test-n5
          10.8.30.35   node35
          10.8.30.36   node36
          10.8.30.37   node37
          10.8.30.38   node38
          fallthrough
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          fallthrough  in-addr.arpa ip6.arpa
          ttl 30
        }
        prometheus :9153
        # upstreamNameservers
        forward . 114.114.114.114 223.5.5.5 {
          max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
    # stubDomains
    k8s.com:53 {
      errors
      cache 30
      forward . 192.168.10.10
    } 
      
```

## 创建一个Ubuntu测试容器



```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test
  labels:
    app: test
spec:
  matchLabels:
    app: test
  replicas: 1
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
      - image: ubuntu:20.04
        name: test
        command: ["/bin/bash","-c","while true; do sleep 1000; done"]
        imagePullPolicy: IfNotPresent
```



## 强制删除某 pod



```shell
kubectl delete pod <pod>  [-n <namespace>] --force --grace-period=0
```



## 使容器内时间与宿主机同步

我们下载的很多容器内的时区都是格林尼治时间，与北京时间差8小时，这将导致容器内的日志和文件创建时间与实际时区不符，有两种方式解决这个问题：

- 修改镜像中的时区配置文件
- 将宿主机的时区配置文件`/etc/localtime`使用volume方式挂载到容器中

第二种方式比较简单，无需重新制作镜像：

```yaml
apiVersion: apps/v1 # for versions before 1.8.0 use apps/v1beta1
kind: Deployment
metadata:
  name: test
  namespace: test
  labels:
    app: test
spec:
  selector:
    matchLabels:
      app: test
  replicas: 1
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
      - name: test
        image: ubuntu:20.04
        volumeMounts:
        - name: localtime
          mountPath: /etc/localtime
      volumes:
      - name: localtime
        hostPath:
          path: /etc/localtime

```



