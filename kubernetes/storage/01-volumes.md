[TOC]



# 卷

大家都知道容器中的数据在磁盘上临时存储的。这样会给一些应用带来一些问题：容器崩溃后 kubelet 会重启一个容器，导致原来容器里的文件丢失。



docker 里也有这个概念，但是docker 里对卷的管理比较简单。相比而言，k8s 支持很多类型的卷。pod 可以使用多个类型的多个卷。

卷 按生命周期大体上分为 临时卷和持久卷：

- 临时卷类型的生命周期与 Pod 相同，当 Pod 不再存在时，Kubernetes 也会销毁临时卷
- 久卷可以比 Pod 的存活期长，Kubernetes 不会销毁 持久卷

对于给定 Pod 中任何类型的卷，在容器重启期间数据都不会丢失。



卷的核心是一个目录，其中可能存有数据，Pod 中的容器可以访问该目录中的数据。 所采用的特定的卷类型将决定该目录如何形成的、使用何种介质保存数据以及目录中存放 的内容。



使用卷时, 在 `.spec.volumes` 字段中设置为 Pod 提供的卷，并在 `.spec.containers[*].volumeMounts` 字段中声明卷在容器中的挂载位置。 各个卷则挂载在容器内的指定路径上， 卷不能挂载到其他卷之上，也不能与其他卷有硬链接。 Pod 配置中的每个容器必须独立指定各个卷的挂载位置。



## 类型



### 云服务商等提供的卷类型

- Amazon 的 awsElasticBlockStore 
- Azure 的 azureDisk 和 azureFile
- google 的 gcePersistentDisk
- vmware 的 vsphereVolume
- 基于 OpenStack  的云 : cinder
- 以 超融合的方式： portworxVolume
- … …



###  k8s  api-resources



#### configMap

`configMap` 卷 提供了向 Pod 注入配置数据的方法。 ConfigMap 对象中存储的数据可以被 `configMap` 类型的卷引用，然后被 Pod 中运行的 容器化应用使用.



引用 configMap 对象时，你可以在 volume 中通过它的名称来引用。 你可以自定义 ConfigMap 中特定条目所要使用的路径。 下面的配置显示了如何将名为 `log-config` 的 ConfigMap 挂载到名为 `configmap-pod` 的 Pod 中：



```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-pod
spec:
  containers:
    - name: test
      image: busybox
      volumeMounts:
        - name: config-vol
          mountPath: /etc/config
  volumes:
    - name: config-vol
      configMap:
        name: log-config
        items:
          - key: log_level
            path: log_level
```



`log-config` ConfigMap 以卷的形式挂载，并且存储在 `log_level` 条目中的所有内容 都被挂载到 Pod 的 `/etc/config/log_level` 路径下。 请注意，这个路径来源于卷的 `mountPath` 和 `log_level` 键对应的 `path`



**说明：**

  - 在使用 `ConfigMap` 之前要先创建

  - 容器以 `subPath`卷的方式使用 ConfigMap 时，无法接收 ConfigMap 的更新

  - 文本数据挂载成文件时采用 `UTF-8` 的字符编码，如果使用其他字符编码，可以使用 `binaryData` 字段





#### persistentVolumeClaim



`persistentVolumeClaim` 卷用来将持久卷（PersistentVolume） 挂载到 Pod 中。 持久卷申领（PersistentVolumeClaim）是用户在不知道特定云环境细节的情况下"申领"持久存储 （例如 GCE PersistentDisk 或者 iSCSI 卷）的一种方法。



#### secret



`secret` 卷用来给 Pod 传递敏感信息，例如密码。你可以将 Secret 存储在 Kubernetes API 服务器上，然后以文件的形式挂在到 Pod 中，无需直接与 Kubernetes 耦合。 `secret` 卷由 tmpfs（基于 RAM 的文件系统）提供存储，因此它们永远不会被写入非易失性 （持久化的）存储器。



**说明：**

    -  使用前你必须在 Kubernetes API 中创建 secret
    -  容器以 subPath 卷挂载方式挂载 Secret 时，将感知不到 Secret 的更新



### k8s 内置



#### emptyDir



当 Pod 分派到某个 Node 上时，`emptyDir` 卷会被创建，并且在 Pod 在该节点上运行期间，卷一直存在。 就像其名称表示的那样，卷最初是空的。 尽管 Pod 中的容器挂载 `emptyDir` 卷的路径可能相同也可能不同，这些容器都可以读写 `emptyDir` 卷中相同的文件。 当 Pod 因为某些原因被从节点上删除时，`emptyDir` 卷中的数据也会被永久删除。



**说明：** 容器崩溃并**不**会导致 Pod 被从节点上移除，因此容器崩溃期间 `emptyDir` 卷中的数据是安全的。



`emptyDir` 的一些用途：

- 缓存空间，例如基于磁盘的归并排序。
- 为耗时较长的计算任务提供检查点，以便任务能方便地从崩溃前状态恢复执行。
- 在 Web 服务器容器服务数据时，保存内容管理器容器获取的文件。

取决于你的环境，`emptyDir` 卷存储在该节点所使用的介质上；这里的介质可以是磁盘或 SSD 或网络存储。但是，你可以将 `emptyDir.medium` 字段设置为 `"Memory"`，以告诉 Kubernetes 为你挂载 tmpfs（基于 RAM 的文件系统）。 虽然 tmpfs 速度非常快，但是要注意它与磁盘不同。 tmpfs 在节点重启时会被清除，并且你所写入的所有文件都会计入容器的内存消耗，受容器内存限制约束。



**说明：** 当启用 `SizeMemoryBackedVolumes` 特性时， 你可以为基于内存提供的卷指定大小。 如果未指定大小，则基于内存的卷的大小为 Linux 主机上内存的 50％。



```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: k8s.gcr.io/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir: {}
```



#### hostPath



**警告：**

HostPath 卷存在许多安全风险，最佳做法是尽可能避免使用 HostPath。 当必须使用 HostPath 卷时，它的范围应仅限于所需的文件或目录，并以只读方式挂载。

如果通过 AdmissionPolicy 限制 HostPath 对特定目录的访问， 则必须要求 `volumeMounts` 使用 `readOnly` 挂载以使策略生效。



`hostPath` 卷能将主机节点文件系统上的文件或目录挂载到你的 Pod 中。 虽然这不是大多数 Pod 需要的，但是它为一些应用程序提供了强大的逃生舱。

例如，`hostPath` 的一些用法有：

- 运行一个需要访问 Docker 内部机制的容器；可使用 `hostPath` 挂载 `/var/lib/docker` 路径。
- 在容器中运行 cAdvisor 时，以 `hostPath` 方式挂载 `/sys`。
- 允许 Pod 指定给定的 `hostPath` 在运行 Pod 之前是否应该存在，是否应该创建以及应该以什么方式存在。

除了必需的 `path` 属性之外，用户可以选择性地为 `hostPath` 卷指定 `type`。



支持的 `type` 值如下：



| 取值                | 行为                                                         |
| :------------------ | :----------------------------------------------------------- |
|                     | 空字符串（默认）用于向后兼容，这意味着在安装 hostPath 卷之前不会执行任何检查。 |
| `DirectoryOrCreate` | 如果在给定路径上什么都不存在，那么将根据需要创建空目录，权限设置为 0755，具有与 kubelet 相同的组和属主信息。 |
| `Directory`         | 在给定路径上必须存在的目录。                                 |
| `FileOrCreate`      | 如果在给定路径上什么都不存在，那么将在那里根据需要创建空文件，权限设置为 0644，具有与 kubelet 相同的组和所有权。 |
| `File`              | 在给定路径上必须存在的文件。                                 |
| `Socket`            | 在给定路径上必须存在的 UNIX 套接字。                         |
| `CharDevice`        | 在给定路径上必须存在的字符设备。                             |
| `BlockDevice`       | 在给定路径上必须存在的块设备。                               |



当使用这种类型的卷时要小心，因为：

- HostPath 卷可能会暴露特权系统凭据（例如 Kubelet）或特权 API（例如容器运行时套接字）， 可用于容器逃逸或攻击集群的其他部分。
- 具有相同配置（例如基于同一 PodTemplate 创建）的多个 Pod 会由于节点上文件的不同 而在不同节点上有不同的行为。
- 下层主机上创建的文件或目录只能由 root 用户写入。你需要在 特权容器 中以 root 身份运行进程，或者修改主机上的文件权限以便容器能够写入 `hostPath` 卷



##### hostPath 配置示例

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: k8s.gcr.io/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /test-pd
      name: test-volume
  volumes:
  - name: test-volume
    hostPath:
      # 宿主上目录位置
      path: /data
      # 此字段为可选
      type: Directory
```



**注意：** `FileOrCreate` 模式不会负责创建文件的父目录。 如果欲挂载的文件的父目录不存在，Pod 启动会失败。 为了确保这种模式能够工作，可以尝试把文件和它对应的目录分开挂载，如 [`FileOrCreate` 配置](https://kubernetes.io/zh/docs/concepts/storage/volumes/#hostpath-fileorcreate-example) 所示。



##### hostPath FileOrCreate 配置示例



```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-webserver
spec:
  containers:
  - name: test-webserver
    image: k8s.gcr.io/test-webserver:latest
    volumeMounts:
    - mountPath: /var/local/aaa
      name: mydir
    - mountPath: /var/local/aaa/1.txt
      name: myfile
  volumes:
  - name: mydir
    hostPath:
      # 确保文件所在目录成功创建。
      path: /var/local/aaa
      type: DirectoryOrCreate
  - name: myfile
    hostPath:
      path: /var/local/aaa/1.txt
      type: FileOrCreate
```



#### local



`local` 卷所代表的是某个被挂载的本地存储设备，例如磁盘、分区或者目录。

`local` 卷只能用作静态创建的持久卷。尚不支持动态配置。

与 `hostPath` 卷相比，`local` 卷能够以持久和可移植的方式使用，而无需手动将 Pod 调度到节点。系统通过查看 PersistentVolume 的节点亲和性配置，就能了解卷的节点约束。

然而，`local` 卷仍然取决于底层节点的可用性，并不适合所有应用程序。 如果节点变得不健康，那么`local` 卷也将变得不可被 Pod 访问。使用它的 Pod 将不能运行。 使用 `local` 卷的应用程序必须能够容忍这种可用性的降低，以及因底层磁盘的耐用性特征 而带来的潜在的数据丢失风险。



下面是一个使用 `local` 卷和 `nodeAffinity` 的持久卷示例：

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: example-pv
spec:
  capacity:
    storage: 100Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage
  local:
    path: /mnt/disks/ssd1
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - example-node
```



使用 `local` 卷时，你需要设置 PersistentVolume 对象的 `nodeAffinity` 字段。 Kubernetes 调度器使用 PersistentVolume 的 `nodeAffinity` 信息来将使用 `local` 卷的 Pod 调度到正确的节点。

PersistentVolume 对象的 `volumeMode` 字段可被设置为 "Block" （而不是默认值 "Filesystem"），以将 `local` 卷作为原始块设备暴露出来。



使用 `local` 卷时，建议创建一个 StorageClass 并将其 `volumeBindingMode` 设置为 `WaitForFirstConsumer`。要了解更多详细信息，请参考 [local StorageClass 示例](https://kubernetes.io/zh/docs/concepts/storage/storage-classes/#local)。 延迟卷绑定的操作可以确保 Kubernetes 在为 PersistentVolumeClaim 作出绑定决策时， 会评估 Pod 可能具有的其他节点约束，例如：如节点资源需求、节点选择器、Pod 亲和性和 Pod 反亲和性。



你可以在 Kubernetes 之外单独运行静态驱动以改进对 local 卷的生命周期管理。 请注意，此驱动尚不支持动态配置。 有关如何运行外部 `local` 卷驱动，请参考 [local 卷驱动用户指南](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner)。



**说明：** 如果不使用外部静态驱动来管理卷的生命周期，用户需要手动清理和删除 local 类型的持久卷。



#### projected



`projected` 卷类型能将若干现有的卷来源映射到同一目录上。

目前，可以映射的卷来源类型如下：

- [`secret`](https://kubernetes.io/zh/docs/concepts/storage/volumes/#secret)
- [`downwardAPI`](https://kubernetes.io/zh/docs/concepts/storage/volumes/#downwardapi)
- [`configMap`](https://kubernetes.io/zh/docs/concepts/storage/volumes/#configmap)
- `serviceAccountToken`

所有的卷来源需要和 Pod 处于相同的命名空间。 更多详情请参考[一体化卷设计文档](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/node/all-in-one-volume.md)。



##### 包含 Secret、downwardAPI 和 configMap 的 Pod 示例



```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-test
spec:
  containers:
  - name: container-test
    image: busybox
    volumeMounts:
    - name: all-in-one
      mountPath: "/projected-volume"
      readOnly: true
  volumes:
  - name: all-in-one
    projected:
      sources:
      - secret:
          name: mysecret
          items:
            - key: username
              path: my-group/my-username
      - downwardAPI:
          items:
            - path: "labels"
              fieldRef:
                fieldPath: metadata.labels
            - path: "cpu_limit"
              resourceFieldRef:
                containerName: container-test
                resource: limits.cpu
      - configMap:
          name: myconfigmap
          items:
            - key: config
              path: my-group/my-config
```



下面是一个带有非默认访问权限设置的多个 secret 的 Pod 示例:



```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-test
spec:
  containers:
  - name: container-test
    image: busybox
    volumeMounts:
    - name: all-in-one
      mountPath: "/projected-volume"
      readOnly: true
  volumes:
  - name: all-in-one
    projected:
      sources:
      - secret:
          name: mysecret
          items:
            - key: username
              path: my-group/my-username
      - secret:
          name: mysecret2
          items:
            - key: password
              path: my-group/my-password
              mode: 511
```



每个被投射的卷来源都在规约中的 `sources` 内列出。参数几乎相同，除了两处例外：

- 对于 `secret`，`secretName` 字段已被变更为 `name` 以便与 ConfigMap 命名一致。
- `defaultMode` 只能在整个投射卷级别指定，而无法针对每个卷来源指定。 不过，如上所述，你可以显式地为每个投射项设置 `mode` 值。

当开启 `TokenRequestProjection` 功能时，可以将当前 [服务帐号](https://kubernetes.io/zh/docs/reference/access-authn-authz/authentication/#service-account-tokens) 的令牌注入 Pod 中的指定路径。 下面是一个例子：



```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sa-token-test
spec:
  containers:
  - name: container-test
    image: busybox
    volumeMounts:
    - name: token-vol
      mountPath: "/service-account"
      readOnly: true
  volumes:
  - name: token-vol
    projected:
      sources:
      - serviceAccountToken:
          audience: api
          expirationSeconds: 3600
          path: token
```



示例 Pod 具有包含注入服务帐户令牌的映射卷。 该令牌可以被 Pod 中的容器用来访问 Kubernetes API 服务器。 `audience` 字段包含令牌的预期受众。 令牌的接收者必须使用令牌的受众中指定的标识符来标识自己，否则应拒绝令牌。 此字段是可选的，默认值是 API 服务器的标识符。



`expirationSeconds` 是服务帐户令牌的有效期时长。 默认值为 1 小时，必须至少 10 分钟（600 秒）。 管理员还可以通过设置 API 服务器的 `--service-account-max-token-expiration` 选项来 限制其最大值。 `path` 字段指定相对于映射卷的挂载点的相对路径。



**说明：**

使用投射卷源作为 [subPath](https://kubernetes.io/zh/docs/concepts/storage/volumes/#using-subpath) 卷挂载的容器将不会接收这些卷源的更新





###  others



#### cephfs



`cephfs` 卷允许你将现存的 CephFS 卷挂载到 Pod 中。 不像 `emptyDir` 那样会在 Pod 被删除的同时也会被删除，`cephfs` 卷的内容在 Pod 被删除 时会被保留，只是卷被卸载了。这意味着 `cephfs` 卷可以被预先填充数据，且这些数据可以在 Pod 之间共享。同一 `cephfs` 卷可同时被多个写者挂载。



**说明：** 在使用 Ceph 卷之前，你的 Ceph 服务器必须已经运行并将要使用的 share 导出（exported）。



#### downwardAPI

`downwardAPI` 卷用于使 downward API 数据对应用程序可用。 这种卷类型挂载一个目录并在纯文本文件中写入所请求的数据。

**说明：** 容器以 subPath 卷挂载方式使用 downwardAPI 时，将不能接收到它的更新。



#### fc (光纤通道)



`fc` 卷类型允许将现有的光纤通道块存储卷挂载到 Pod 中。 可以使用卷配置中的参数 `targetWWNs` 来指定单个或多个目标 WWN（World Wide Names）。 如果指定了多个 WWN，targetWWNs 期望这些 WWN 来自多路径连接。

**说明：** 你必须配置 FC SAN Zoning，以便预先向目标 WWN 分配和屏蔽这些 LUN（卷）， 这样 Kubernetes 主机才可以访问它们。



#### glusterfs



`glusterfs` 卷能将 [Glusterfs](https://www.gluster.org/) (一个开源的网络文件系统) 挂载到你的 Pod 中。不像 `emptyDir` 那样会在删除 Pod 的同时也会被删除，`glusterfs` 卷的内容在删除 Pod 时会被保存，卷只是被卸载。 这意味着 `glusterfs` 卷可以被预先填充数据，并且这些数据可以在 Pod 之间共享。 GlusterFS 可以被多个写者同时挂载。

**说明：** 在使用前你必须先安装运行自己的 GlusterFS。





#### iscsi



`iscsi` 卷能将 iSCSI (基于 IP 的 SCSI) 卷挂载到你的 Pod 中。 不像 `emptyDir` 那样会在删除 Pod 的同时也会被删除，`iscsi` 卷的内容在删除 Pod 时 会被保留，卷只是被卸载。 这意味着 `iscsi` 卷可以被预先填充数据，并且这些数据可以在 Pod 之间共享。



**注意：** 在使用 iSCSI 卷之前，你必须拥有自己的 iSCSI 服务器，并在上面创建卷。



iSCSI 的一个特点是它可以同时被多个用户以只读方式挂载。 这意味着你可以用数据集预先填充卷，然后根据需要在尽可能多的 Pod 上使用它。 不幸的是，iSCSI 卷只能由单个使用者以读写模式挂载。不允许同时写入。



#### nfs



`nfs` 卷能将 NFS (网络文件系统) 挂载到你的 Pod 中。 不像 `emptyDir` 那样会在删除 Pod 的同时也会被删除，`nfs` 卷的内容在删除 Pod 时会被保存，卷只是被卸载。 这意味着 `nfs` 卷可以被预先填充数据，并且这些数据可以在 Pod 之间共享。



**注意：** 在使用 NFS 卷之前，你必须运行自己的 NFS 服务器并将目标 share 导出备用。



#### rbd



`rbd` 卷允许将 [Rados 块设备](https://docs.ceph.com/en/latest/rbd/) 卷挂载到你的 Pod 中. 不像 `emptyDir` 那样会在删除 Pod 的同时也会被删除，`rbd` 卷的内容在删除 Pod 时 会被保存，卷只是被卸载。 这意味着 `rbd` 卷可以被预先填充数据，并且这些数据可以在 Pod 之间共享。



**注意：** 在使用 RBD 之前，你必须安装运行 Ceph。



RBD 的一个特性是它可以同时被多个用户以只读方式挂载。 这意味着你可以用数据集预先填充卷，然后根据需要在尽可能多的 Pod 中并行地使用卷。 不幸的是，RBD 卷只能由单个使用者以读写模式安装。不允许同时写入。



## 使用 subPath



有时，在单个 Pod 中共享卷以供多方使用是很有用的。 `volumeMounts.subPath` 属性可用于指定所引用的卷内的子路径，而不是其根路径。



下面例子展示了如何配置某包含 LAMP 堆栈（Linux Apache MySQL PHP）的 Pod 使用同一共享卷。 此示例中的 `subPath` 配置不建议在生产环境中使用。 PHP 应用的代码和相关数据映射到卷的 `html` 文件夹，MySQL 数据库存储在卷的 `mysql` 文件夹中：



```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-lamp-site
spec:
    containers:
    - name: mysql
      image: mysql
      env:
      - name: MYSQL_ROOT_PASSWORD
        value: "rootpasswd"
      volumeMounts:
      - mountPath: /var/lib/mysql
        name: site-data
        subPath: mysql
    - name: php
      image: php:7.0-apache
      volumeMounts:
      - mountPath: /var/www/html
        name: site-data
        subPath: html
    volumes:
    - name: site-data
      persistentVolumeClaim:
        claimName: my-lamp-site-data
```



下面我们自己项目使用的一个栗子：



```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: fs-party
  namespace: free-sun
  labels:
    app: fs-party
spec:
  replicas: 1
  selector:
    matchLabels:
      app: fs-party
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: fs-party
    spec:
      volumes:
        - name: resources-volume
          persistentVolumeClaim:
            claimName: fs-party-pvc
      containers:
        - name: fs-party
          image: 'repository.anxinyun.cn/fsparty/fsparty:v1.7'
          ports:
            - name: port-8080
              containerPort: 8080
              protocol: TCP
            - name: port-443
              containerPort: 443
              protocol: TCP
          resources:
            requests:
              cpu: 100m
              memory: 100Mi
          volumeMounts:
            - name: resources-volume
              mountPath: /workspace/pros/data/config.php
              subPath: party/config.php
            - name: resources-volume
              mountPath: /etc/nginx/cert
              subPath: party/cert

```





### 使用带有扩展环境变量的 subPath



使用 `subPathExpr` 字段可以基于 Downward API 环境变量来构造 `subPath` 目录名。 `subPath` 和 `subPathExpr` 属性是互斥的。



在这个示例中，Pod 使用 `subPathExpr` 来 hostPath 卷 `/var/log/pods` 中创建目录 `pod1`。 `hostPath` 卷采用来自 `downwardAPI` 的 Pod 名称生成目录名。 宿主目录 `/var/log/pods/pod1` 被挂载到容器的 `/logs` 中。



```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod1
spec:
  containers:
  - name: container1
    env:
    - name: POD_NAME
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: metadata.name
    image: busybox
    command: [ "sh", "-c", "while [ true ]; do echo 'Hello'; sleep 10; done | tee -a /logs/hello.txt" ]
    volumeMounts:
    - name: workdir1
      mountPath: /logs
      subPathExpr: $(POD_NAME)
  restartPolicy: Never
  volumes:
  - name: workdir1
    hostPath:
      path: /var/log/pods
```



# 总结

volume 功能：

- 数据共享
- 数据持久化

类型：

- configMap 
- secret
- emptyDir
- hostPath
- local
- nfs
- cephfs
- … …

