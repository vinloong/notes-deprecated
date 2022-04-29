
init 容器是一种特殊的容器，在 pod 内的应用容器启动之前运行，可以存在多个，运行顺序按照配置中声明的顺序运行，并且每个完成之后才会运行下一个

应用：
可以在init容器中定义pod 中应用服务的依赖，当pod 中容器的所有条件都满足时再启动pod,从而来实现定义pod 启动顺序。

```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: web-console
  namespace: anxincloud
  labels:
    app: web-console
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-console
  template:
    metadata:
      labels:
        app: web-console
    spec:
      initContainers
        - name: init-webapi
          image: busybox:1.28
          command: ['sh', '-c', "until nslookup api-anxincloud.anxincloud.svc.cluster.local; do echo 'waiting for web api'; sleep 2; done"]
      containers:
        - name: web-console
          image: 'repository.anxinyun.cn/anxinyun/console-web:145.22-04-13'
          command:
            - node
            - server.js
          ports:
            - name: web
              containerPort: 8080
              protocol: TCP
          envFrom:
            - configMapRef:
                name: cm-anxincloud
```


