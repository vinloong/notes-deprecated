# 升级集群



## k8s 版本信息

k8s 版本表示为`x.y.z`，其中`x`是主要版本，`y`是次要版本，`z`是补丁版本。

### k8s 发行版与 github 分支的关系

master分支上的代码是最新的，每隔2周会生成一个发布版本(release)，由新到旧以此为 `master`-->`alpha`-->`beta`-->`Final release`。`X.Y.0`为稳定版本，一个`X.Y.0`版本会在`X.(Y-1).0`版本的3到4个月后出现，`X.Y.Z`为解决了必须的安全性漏洞、以及影响大量用户的无法解决的问题的补丁版本。总体而言，我们一般关心`X.Y.0`(稳定版本)，和`X.Y.Z`(补丁版本)的特性。

`v1.14.0` : `1`为主要版本 : `14`为次要版本 : `0`为补丁版本

### 每个版本的支持周期

`k8s` 项目维护最新三个次要版本的发布分支。结合上述**一个`X.Y.0`版本会在`X.(Y-1).0`版本的3到4个月后出现**的描述，也就是说1年前的版本就不再维护，每个次要版本的维护周期为9~12个月，就算有安全漏洞也不会有补丁版本.

`k8s` 项目会维护最近的三个小版本分支（1.23, 1.22, 1.21）。 `k8s` 1.19 及更高的版本将获得大约1年的补丁支持。 `k8s` 1.18 及更早的版本获得大约9个月的补丁支持。

## 版本兼容性

### kube-apiserver

在高可用的集群中，多个`kube-apiserver` 实例的小版本号最多差 1

- 比如我们的集群 `kube-apiserver` 版本号如果是 **1.18**
- 则受支持的 `kube-apiserver` 版本号包括 **1.18** 和 **1.19**

### kubelet

`kubelet` 版本号不能高于 `kube-apiserver`，最多可以比 `kube-apiserver` 低两个小版本。

例如：

- `kube-apiserver` 版本号如果是 **1.20**
- 受支持的的 `kubelet` 版本将包括 **1.20**、**1.19** 和 **1.18**

> 如果 HA 集群中多个 `kube-apiserver` 实例版本号不一致，相应的 `kubelet` 版本号可选范围也要减小



### kube-controller-manager、 kube-scheduler 和 cloud-controller-manager

`kube-controller-manager`、`kube-scheduler` 和 `cloud-controller-manager` 版本不能高于 `kube-apiserver` 版本号。 最好它们的版本号与 `kube-apiserver` 保持一致，但允许比 `kube-apiserver` 低一个小版本（为了支持在线升级）。

例如：

- 如果 `kube-apiserver` 版本号为 **1.20**
- `kube-controller-manager`、`kube-scheduler` 和 `cloud-controller-manager` 版本支持 **1.20** 和 **1.19**



> **说明：** 如果在 HA 集群中，多个 `kube-apiserver` 实例版本号不一致，他们也可以跟任意一个 `kube-apiserver` 实例通信（例如，通过 load balancer）， 但 `kube-controller-manager`、`kube-scheduler` 和 `cloud-controller-manager` 版本可用范围会相应的减小。

例如：

- `kube-apiserver` 实例同时存在 **1.20** 和 **1.21** 版本
- `kube-controller-manager`、`kube-scheduler` 和 `cloud-controller-manager` 可以通过 `load balancer` 与所有的 `kube-apiserver` 通信
- `kube-controller-manager`、`kube-scheduler` 和 `cloud-controller-manager` 可选版本为 **1.20** （不支持**1.21** 因为它比  `kube-apiserver`  的版本 **1.20** 新）

### kubectl

`kubectl` 可以比 `kube-apiserver` 高一个小版本，也可以低一个小版本。

例如：

- 如果 `kube-apiserver` 当前是 **1.22** 版本
- `kubectl` 则支持 **1.23**、**1.22** 和 **1.21**

> **说明：** 如果 HA 集群中的多个 `kube-apiserver` 实例版本号不一致，相应的 `kubectl` 可用版本范围也会减小。

例如：

- `kube-apiserver` 多个实例同时存在 **1.23** 和 **1.22**
- `kubectl` 可选的版本为 **1.23** 和 **1.22**（其他版本不再支持，因为它会比其中某个 `kube-apiserver` 实例高或低一个小版本



## 升级集群

我们集群是由 `kubeadm` 部署的，版本是 `1.18.x`,目前最新版本是 1.23, 最新稳定版是 1.22

下面详细介绍下集群从`1.18.x` 版本升级到 `1.19.x`，简单说下其他版本升级需要注意的细节。

备注：

- 升级后，因为容器规约的哈希值已更改，所有容器都会重启。
- 只能从一个次版本升级到下一个次版本，或者在次版本相同时升级补丁版本。 也就是说，升级时不可以跳过次版本。 例如，你只能从 `1.y` 升级到` 1.y+1`，而不能从 from `1.y` 升级到 `1.y+2`。

**升级的基本流程：**

1. 先升级主控制平面节点再升级其他控制平面节点最后升级工作节点
2. 先升级 `kube-apiserver` 再升级 `kube-controller-manager`、`kube-scheduler` 然后升级 `kubelet`最后升级 `kube-proxy`

### 升级控制节点

#### 升级主控节点

```shell
apt update
apt-cache policy kubeadm
# 用最新的修补程序版本替换 1.19.x-00 中的 x
apt-mark unhold kubeadm && \
apt-get update && apt-get install -y kubeadm=1.19.x-00 && \
apt-mark hold kubeadm

# 从 apt-get 1.1 版本起，你也可以使用下面的方法
apt-get update && \
apt-get install -y --allow-change-held-packages kubeadm=1.19.x-00
```

升级完成，验证：

```shell
kubeadm version
```

腾空控制平面节点:

```shell
# 将 <cp-node-name> 替换为你自己的控制面节点名称
kubectl drain <cp-node-name> --ignore-daemonsets
```

检查集群是否可以升级，并可以获取到升级的版本

```shell
sudo kubeadm upgrade plan
```

类似下面的输出：

```
[upgrade/config] Making sure the configuration is correct:
[upgrade/config] Reading configuration from the cluster...
[upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[preflight] Running pre-flight checks.
[upgrade] Running cluster health checks
[upgrade] Fetching available versions to upgrade to
[upgrade/versions] Cluster version: v1.18.4
[upgrade/versions] kubeadm version: v1.19.0
[upgrade/versions] Latest stable version: v1.19.0
[upgrade/versions] Latest version in the v1.18 series: v1.18.4

Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   CURRENT             AVAILABLE
Kubelet     1 x v1.18.4         v1.19.0

Upgrade to the latest version in the v1.18 series:

COMPONENT            CURRENT   AVAILABLE
API Server           v1.18.4   v1.19.0
Controller Manager   v1.18.4   v1.19.0
Scheduler            v1.18.4   v1.19.0
Kube Proxy           v1.18.4   v1.19.0
CoreDNS              1.6.7     1.7.0
Etcd                 3.4.3-0   3.4.7-0

You can now apply the upgrade by executing the following command:

    kubeadm upgrade apply v1.19.0

_____________________________________________________________________

  The table below shows the current state of component configs as understood by this version of kubeadm.
  Configs that have a "yes" mark in the "MANUAL UPGRADE REQUIRED" column require manual config upgrade or
  resetting to kubeadm defaults before a successful upgrade can be performed. The version to manually
  upgrade to is denoted in the "PREFERRED VERSION" column.

  API GROUP                 CURRENT VERSION   PREFERRED VERSION   MANUAL UPGRADE REQUIRED
  kubeproxy.config.k8s.io   v1alpha1          v1alpha1            no
  kubelet.config.k8s.io     v1beta1           v1beta1             no
  _____________________________________________________________________
```



> **说明：**如果 `kubeadm upgrade plan` 显示有任何组件配置需要手动升级，则用户必须 通过命令行参数 `--config` 给 `kubeadm upgrade apply` 操作 提供带有替换配置的配置文件。

升级到1.19版本

```shell
# 将 x 替换为你为此次升级所选的补丁版本号
sudo kubeadm upgrade apply v1.19.x
```

看到类似下面的输出：

```
[upgrade/config] Making sure the configuration is correct:
[upgrade/config] Reading configuration from the cluster...
[upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[preflight] Running pre-flight checks.
[upgrade] Running cluster health checks
[upgrade/version] You have chosen to change the cluster version to "v1.19.0"
[upgrade/versions] Cluster version: v1.18.4
[upgrade/versions] kubeadm version: v1.19.0
[upgrade/confirm] Are you sure you want to proceed with the upgrade? [y/N]: y
[upgrade/prepull] Pulling images required for setting up a Kubernetes cluster
[upgrade/prepull] This might take a minute or two, depending on the speed of your internet connection
[upgrade/prepull] You can also perform this action in beforehand using 'kubeadm config images pull'
[upgrade/apply] Upgrading your Static Pod-hosted control plane to version "v1.19.0"...
Static pod: kube-apiserver-kind-control-plane hash: b4c8effe84b4a70031f9a49a20c8b003
Static pod: kube-controller-manager-kind-control-plane hash: 9ac092f0ca813f648c61c4d5fcbf39f2
Static pod: kube-scheduler-kind-control-plane hash: 7da02f2c78da17af7c2bf1533ecf8c9a
[upgrade/etcd] Upgrading to TLS for etcd
Static pod: etcd-kind-control-plane hash: 171c56cd0e81c0db85e65d70361ceddf
[upgrade/staticpods] Preparing for "etcd" upgrade
[upgrade/staticpods] Renewing etcd-server certificate
[upgrade/staticpods] Renewing etcd-peer certificate
[upgrade/staticpods] Renewing etcd-healthcheck-client certificate
[upgrade/staticpods] Moved new manifest to "/etc/kubernetes/manifests/etcd.yaml" and backed up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2020-07-13-16-24-16/etcd.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This might take a minute or longer depending on the component/version gap (timeout 5m0s)
Static pod: etcd-kind-control-plane hash: 171c56cd0e81c0db85e65d70361ceddf
Static pod: etcd-kind-control-plane hash: 171c56cd0e81c0db85e65d70361ceddf
Static pod: etcd-kind-control-plane hash: 59e40b2aab1cd7055e64450b5ee438f0
[apiclient] Found 1 Pods for label selector component=etcd
[upgrade/staticpods] Component "etcd" upgraded successfully!
[upgrade/etcd] Waiting for etcd to become available
[upgrade/staticpods] Writing new Static Pod manifests to "/etc/kubernetes/tmp/kubeadm-upgraded-manifests999800980"
[upgrade/staticpods] Preparing for "kube-apiserver" upgrade
[upgrade/staticpods] Renewing apiserver certificate
[upgrade/staticpods] Renewing apiserver-kubelet-client certificate
[upgrade/staticpods] Renewing front-proxy-client certificate
[upgrade/staticpods] Renewing apiserver-etcd-client certificate
[upgrade/staticpods] Moved new manifest to "/etc/kubernetes/manifests/kube-apiserver.yaml" and backed up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2020-07-13-16-24-16/kube-apiserver.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This might take a minute or longer depending on the component/version gap (timeout 5m0s)
Static pod: kube-apiserver-kind-control-plane hash: b4c8effe84b4a70031f9a49a20c8b003
Static pod: kube-apiserver-kind-control-plane hash: b4c8effe84b4a70031f9a49a20c8b003
Static pod: kube-apiserver-kind-control-plane hash: b4c8effe84b4a70031f9a49a20c8b003
Static pod: kube-apiserver-kind-control-plane hash: b4c8effe84b4a70031f9a49a20c8b003
Static pod: kube-apiserver-kind-control-plane hash: f717874150ba572f020dcd89db8480fc
[apiclient] Found 1 Pods for label selector component=kube-apiserver
[upgrade/staticpods] Component "kube-apiserver" upgraded successfully!
[upgrade/staticpods] Preparing for "kube-controller-manager" upgrade
[upgrade/staticpods] Renewing controller-manager.conf certificate
[upgrade/staticpods] Moved new manifest to "/etc/kubernetes/manifests/kube-controller-manager.yaml" and backed up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2020-07-13-16-24-16/kube-controller-manager.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This might take a minute or longer depending on the component/version gap (timeout 5m0s)
Static pod: kube-controller-manager-kind-control-plane hash: 9ac092f0ca813f648c61c4d5fcbf39f2
Static pod: kube-controller-manager-kind-control-plane hash: b155b63c70e798b806e64a866e297dd0
[apiclient] Found 1 Pods for label selector component=kube-controller-manager
[upgrade/staticpods] Component "kube-controller-manager" upgraded successfully!
[upgrade/staticpods] Preparing for "kube-scheduler" upgrade
[upgrade/staticpods] Renewing scheduler.conf certificate
[upgrade/staticpods] Moved new manifest to "/etc/kubernetes/manifests/kube-scheduler.yaml" and backed up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2020-07-13-16-24-16/kube-scheduler.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This might take a minute or longer depending on the component/version gap (timeout 5m0s)
Static pod: kube-scheduler-kind-control-plane hash: 7da02f2c78da17af7c2bf1533ecf8c9a
Static pod: kube-scheduler-kind-control-plane hash: 260018ac854dbf1c9fe82493e88aec31
[apiclient] Found 1 Pods for label selector component=kube-scheduler
[upgrade/staticpods] Component "kube-scheduler" upgraded successfully!
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.19" in namespace kube-system with the configuration for the kubelets in the cluster
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
W0713 16:26:14.074656    2986 dns.go:282] the CoreDNS Configuration will not be migrated due to unsupported version of CoreDNS. The existing CoreDNS Corefile configuration and deployment has been retained.
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.19.0". Enjoy!

[upgrade/kubelet] Now that your control plane is upgraded, please proceed with upgrading your kubelets if you haven't already done so.
```

下面手动升级 `CNI`驱动插件;

取消对控制面节点的保护:

```shell
# 将 <cp-node-name> 替换为你的控制面节点名称
kubectl uncordon <cp-node-name>
```

#### 升级其他控制节点

与第一个控制面节点类似，不过使用下面的命令：

```
sudo kubeadm upgrade node
```

同时，也不需要执行 `sudo kubeadm upgrade plan`

#### 升级 kubelet 和 kubectl

```shell
# 用最新的补丁版本替换 1.19.x-00 中的 x
apt-mark unhold kubelet kubectl && \
apt-get update && apt-get install -y kubelet=1.19.x-00 kubectl=1.19.x-00 && \
apt-mark hold kubelet kubectl

# 从 apt-get 的 1.1 版本开始，你也可以使用下面的方法：

apt-get update && \
apt-get install -y --allow-change-held-packages kubelet=1.19.x-00 kubectl=1.19.x-00
```

重启 kubelet

```shell
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

### 升级工作节点

工作节点上的升级过程应该一次执行一个节点，或者一次执行几个节点， 以不影响运行工作负载所需的最小容量



#### 升级 kubeadm

在所有工作节点升级 kubeadm:

```shell
# 将 1.19.x-00 中的 x 替换为最新的补丁版本
apt-mark unhold kubeadm && \
apt-get update && apt-get install -y kubeadm=1.19.x-00 && \
apt-mark hold kubeadm

# 从 apt-get 的 1.1 版本开始，你也可以使用下面的方法：

apt-get update && \
apt-get install -y --allow-change-held-packages kubeadm=1.19.x-00
```

#### 腾空节点

通过将节点标记为不可调度并逐出工作负载，为维护做好准备。运行：

```shell
# 将 <node-to-drain> 替换为你正在腾空的节点的名称
kubectl drain <node-to-drain> --ignore-daemonsets
```

你应该可以看见与下面类似的输出：

```shell
node/ip-172-31-85-18 cordoned
WARNING: ignoring DaemonSet-managed Pods: kube-system/kube-proxy-dj7d7, kube-system/weave-net-z65qx
node/ip-172-31-85-18 drained
```

#### 升级 kubelet 配置

升级 kubelet 配置:

```shell
sudo kubeadm upgrade node
```

#### 升级 kubelet 与 kubectl

在所有工作节点上升级 kubelet 和 kubectl：

```shell
# 将 1.19.x-00 中的 x 替换为最新的补丁版本
apt-mark unhold kubelet kubectl && \
apt-get update && apt-get install -y kubelet=1.19.x-00 kubectl=1.19.x-00 && \
apt-mark hold kubelet kubectl

# 从 apt-get 的 1.1 版本开始，你也可以使用下面的方法：

apt-get update && \
apt-get install -y --allow-change-held-packages kubelet=1.19.x-00 kubectl=1.19.x-00
```

重启 kubelet

```shell
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

### 取消对节点的保护

通过将节点标记为可调度，让节点重新上线:

```shell
# 将 <node-to-drain> 替换为当前节点的名称
kubectl uncordon <node-to-drain>
```



### 验证集群的状态

在所有节点上升级 kubelet 后，通过从 kubectl 可以访问集群的任何位置运行以下命令，验证所有节点是否再次可用：

```shell
kubectl get nodes
```



## 从故障状态恢复

如果 `kubeadm upgrade` 失败并且没有回滚，例如由于执行期间意外关闭，你可以再次运行 `kubeadm upgrade`。 此命令是幂等的，并最终确保实际状态是你声明的所需状态。 要从故障状态恢复，你还可以运行 `kubeadm upgrade --force` 而不去更改集群正在运行的版本。

在升级期间，kubeadm 向 `/etc/kubernetes/tmp` 目录下的如下备份文件夹写入数据：

- `kubeadm-backup-etcd-<date>-<time>`
- `kubeadm-backup-manifests-<date>-<time>`

`kubeadm-backup-etcd` 包含当前控制面节点本地 etcd 成员数据的备份。 如果 etcd 升级失败并且自动回滚也无法修复，则可以将此文件夹中的内容复制到 `/var/lib/etcd` 进行手工修复。如果使用的是外部的 etcd，则此备份文件夹为空。

`kubeadm-backup-manifests` 包含当前控制面节点的静态 Pod 清单文件的备份版本。 如果升级失败并且无法自动回滚，则此文件夹中的内容可以复制到 `/etc/kubernetes/manifests` 目录实现手工恢复。 如果由于某些原因，在升级前后某个组件的清单未发生变化，则 kubeadm 也不会为之 生成备份版本。



## 工作原理

`kubeadm upgrade apply` 做了以下工作：

- 检查你的集群是否处于可升级状态:
  - API 服务器是可访问的
  - 所有节点处于 `Ready` 状态
  - 控制面是健康的
- 强制执行版本偏差策略。
- 确保控制面的镜像是可用的或可拉取到服务器上。
- 如果组件配置要求版本升级，则生成替代配置与/或使用用户提供的覆盖版本配置。
- 升级控制面组件或回滚（如果其中任何一个组件无法启动）。
- 应用新的 `kube-dns` 和 `kube-proxy` 清单，并强制创建所有必需的 RBAC 规则。
- 如果旧文件在 180 天后过期，将创建 API 服务器的新证书和密钥文件并备份旧文件。

`kubeadm upgrade node` 在其他控制平节点上执行以下操作：

- 从集群中获取 kubeadm `ClusterConfiguration`。
- 可选地备份 kube-apiserver 证书。
- 升级控制平面组件的静态 Pod 清单。
- 为本节点升级 kubelet 配置

`kubeadm upgrade node` 在工作节点上完成以下工作：

- 从集群取回 kubeadm `ClusterConfiguration`。
- 为本节点升级 kubelet 配置



## 引用

[Kubernetes 版本及版本偏差支持策略 | Kubernetes](https://v1-19.docs.kubernetes.io/zh/docs/setup/release/version-skew-policy/)

[升级 kubeadm 集群 | Kubernetes](https://v1-19.docs.kubernetes.io/zh/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)







