k8s 声明式 API

下面举个例子简单说明下什么是声明式：



我们知道，docker 的编排是基于命令行的：



```shell
$ docker run --name nginx --replicas 2  nginx
```

对于这种使用方式，我们称为之为：**命令式命令行操作**。



那么在k8s 中呢，你一定也已经很熟悉了：我们先要编写一个 deployment 的yaml文件：

nginx.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```



然后，再执行下面的命令：

```shell
$ kubectl create -f nginx.yaml
```



这样这个nginx 容器就跑起来了。



而如果要更新这两个 Pod 使用的 Nginx 镜像，该怎么办呢？

可以使用 `kubectl set image` 和 `kubectl edit` 命令，来直接修改 Kubernetes 里的 API 对象。不过，现在我们很多人都通过修改本地 YAML 文件来完成这个操作，这样我的改动就会体现在这个本地 YAML 文件里了:



```yaml
...
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
```



而接下来，我们就可以执行一句 `kubectl replace` 操作，来完成这个 Deployment 的更新：



```shell
$ kubectl replace -f nginx.yaml
```



可是，上面这种基于 YAML 文件的操作方式，是“声明式 API”吗 ?

并不是。

对于上面这种先 kubectl create，再 replace 的操作，我们称为**命令式配置文件操作**。



也就是说，它的处理方式，其实跟前面 Docker 的命令，没什么本质上的区别。只不过，它是把 Docker 命令行里的参数，写在了配置文件里而已。



那么，到底什么才是“声明式 API”呢？



答案是，`kubectl apply` 命令。



在之前我跟很多同事说过使用这个 `kubectl apply` 命令，代替 kubectl create 命令:



```shell
$ kubectl apply -f nginx.yaml
```



这样，Nginx 的 Deployment 就被创建了出来，这看起来跟 `kubectl create` 的效果一样.



然后，我再修改一下 nginx.yaml 里定义的镜像：



```yaml
...
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
```



这时候，关键来了。

在修改完这个 YAML 文件之后，我不再使用 `kubectl replace` 命令进行更新，而是继续执行一条 `kubectl apply` 命令，即：



```shell
$ kubectl apply -f nginx.yaml
```



这时，Kubernetes 就会立即触发这个 Deployment 的“滚动更新”。



可是，它跟 `kubectl replace` 命令有什么本质区别吗？



实际上，你可以简单地理解为，`kubectl replace` 的执行过程，是使用新的 YAML 文件中的 API 对象，替换原有的 API 对象；而 `kubectl apply`，则是执行了一个对原有 API 对象的 PATCH 操作。类似，`kubectl set image` 和 `kubectl edit` 也是对已有 API 对象的修改。



更进一步地，这意味着 `kube-apiserver` 在响应命令式请求（比如，`kubectl replace`）的时候，一次只能处理一个写请求，否则会有产生冲突的可能。而对于声明式请求（比如:`kubectl apply`），一次能处理多个写操作，并且具备 Merge 能力。



这种区别，可能听起来没那么重要。而且，正是由于要照顾到这样的 API 设计，做同样一件事情，Kubernetes 需要的步骤往往要比其他项目多不少。



但是，如果你仔细思考一下 Kubernetes 项目的工作流程，就不难体会到这种声明式 API 的独到之处。



> > TODO add example



- 首先，所谓“声明式”，指的就是我只需要提交一个定义好的 API 对象来“声明”，我所期望的状态是什么样子。
- 其次，“声明式 API”允许有多个 API 写端，以 PATCH 的方式对 API 对象进行修改，而无需关心本地原始 YAML 文件的内容。
- 最后，也是最重要的，有了上述两个能力，Kubernetes 项目才可以基于对 API 对象的增、删、改、查，在完全无需外界干预的情况下，完成对“实际状态”和“期望状态”的调谐（Reconcile）过程。



声明式 API，才是 Kubernetes 项目编排能力“赖以生存”的核心所在。







