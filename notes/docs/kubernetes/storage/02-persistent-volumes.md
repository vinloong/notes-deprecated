[TOC]



# 持久卷

## 简介

在 k8s  中 PersistentVolume  子模块提供了一组 API ： 将存储如何供应的细节从其如何被使用中抽象出来。

为了实现这点，又引入了两个 API 资源：`PersistentVolume` 和 `PersistentVolumeClaim`。



持久卷（PersistentVolume，PV）是集群中的一块存储，可以由管理员事先供应，或者 使用[存储类（Storage Class）](https://kubernetes.io/zh/docs/concepts/storage/storage-classes/)来动态供应。 持久卷是集群资源，就像节点也是集群资源一样。PV 持久卷和普通的 Volume 一样，也是使用 卷插件来实现的，只是它们拥有独立于任何使用 PV 的 Pod 的生命周期。 此 API 对象中记述了存储的实现细节，无论其背后是 NFS、iSCSI 还是特定于云平台的存储系统。



持久卷申领（PersistentVolumeClaim，PVC）表达的是用户对存储的请求。概念上与 Pod 类似。 Pod 会耗用节点资源，而 PVC 申领会耗用 PV 资源。Pod 可以请求特定数量的资源（CPU 和内存）；同样 PVC 申领也可以请求特定的大小和访问模式 （例如，可以要求 PV 卷能够以 ReadWriteOnce、ReadOnlyMany 或 ReadWriteMany 模式之一来挂载，参见[访问模式](https://kubernetes.io/zh/docs/concepts/storage/persistent-volumes/#access-modes)）。尽管 PersistentVolumeClaim 允许用户消耗抽象的存储资源，常见的情况是针对不同的 问题用户需要的是具有不同属性（如，性能）的 PersistentVolume 卷。 集群管理员需要能够提供不同性质的 PersistentVolume，并且这些 PV 卷之间的差别不 仅限于卷大小和访问模式，同时又不能将卷是如何实现的这些细节暴露给用户。 为了满足这类需求，就有了 *存储类（StorageClass）* 资源。



StorageClass 为管理员提供了描述存储 "类" 的方法。 不同的类型可能会映射到不同的服务质量等级或备份策略，或是由集群管理员制定的任意策略。 Kubernetes 本身并不清楚各种类代表的什么。这个类的概念在其他存储系统中有时被称为 "配置文件". 每个 StorageClass 都包含 `provisioner`、`parameters` 和 `reclaimPolicy` 字段， 这些字段会在 StorageClass 需要动态分配 PersistentVolume 时会使用到。StorageClass 对象的命名很重要，用户使用这个命名来请求生成一个特定的类。 当创建 StorageClass 对象时，管理员设置 StorageClass 对象的命名和其他参数，一旦创建了对象就不能再对其更新。



## 卷和申领的生命周期

PV 卷是集群中的资源。PVC 申领是对这些资源的请求，也被用来执行对资源的申领检查。 PV 卷和 PVC 申领之间的互动遵循如下生命周期：

### 供应

PV 卷的供应有两种方式：静态供应或动态供应。

#### 静态供应

集群管理员创建若干 PV 卷。这些卷对象带有真实存储的细节信息，并且对集群 用户可用（可见）。PV 卷对象存在于 Kubernetes API 中，可供用户消费（使用）



#### 动态供应 

如果管理员所创建的所有静态 PV 卷都无法与用户的 PersistentVolumeClaim 匹配， 集群可以尝试为该 PVC 申领动态供应一个存储卷。 这一供应操作是基于 StorageClass 来实现的：PVC 申领必须请求某个 [存储类](https://kubernetes.io/zh/docs/concepts/storage/storage-classes/)，同时集群管理员必须 已经创建并配置了该类，这样动态供应卷的动作才会发生。 如果 PVC 申领指定存储类为 `""`，则相当于为自身禁止使用动态供应的卷。

为了基于存储类完成动态的存储供应，集群管理员需要在 API 服务器上启用 `DefaultStorageClass` [设置授权](https://kubernetes.io/zh/docs/reference/access-authn-authz/admission-controllers/#defaultstorageclass)。 举例而言，可以通过保证 `DefaultStorageClass` 出现在 API 服务器组件的 `--enable-admission-plugins` 标志值中实现这点；该标志的值可以是逗号 分隔的有序列表。关于 API 服务器标志的更多信息，可以参考 [kube-apiserver](https://kubernetes.io/zh/docs/reference/command-line-tools-reference/kube-apiserver/) 文档。



