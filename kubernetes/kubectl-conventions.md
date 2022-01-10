`kubectl` 的推荐用法约定。



## 在可重用脚本中使用 `kubectl`


对于脚本中的稳定输出：


* 请求一个面向机器的输出格式，例如 `-o name`、`-o json`、`-o yaml`、`-o go template` 或 `-o jsonpath`。
* 完全限定版本。例如 `jobs.v1.batch/myjob`。这将确保 kubectl 不会使用其默认版本，该版本会随着时间的推移而更改。
* 不要依赖上下文、首选项或其他隐式状态。


## 最佳实践

### `kubectl run`


若希望 `kubectl run` 满足基础设施即代码的要求：


* 使用特定版本的标签标记镜像，不要将该标签移动到新版本。例如，使用 `:v1234`、`v1.2.3`、`r03062016-1-4`，而不是 `:latest`（有关详细信息，请参阅[配置的最佳实践](/zh/docs/concepts/configuration/overview/#container-images))。
* 使用基于版本控制的脚本来运行包含大量参数的镜像。
* 对于无法通过 `kubectl run` 参数来表示的功能特性，使用基于源码控制的配置文件，以记录要使用的功能特性。


你可以使用 `--dry-run=client` 参数来预览而不真正提交即将下发到集群的对象实例：



>  所有的 `kubectl run` 生成器已弃用。查阅 Kubernetes v1.17 文档中的生成器[列表](https://v1-17.docs.kubernetes.io/docs/reference/kubectl/conventions/#generators)以及它们的用法。



#### 生成器

你可以使用 kubectl 命令生成以下资源， `kubectl create --dry-run=client -o yaml`：

* `clusterrole`:         创建 ClusterRole。
* `clusterrolebinding`:  为特定的 ClusterRole 创建 ClusterRoleBinding。
* `configmap`:           使用本地文件、目录或文本值创建 Configmap。
* `cronjob`:             使用指定的名称创建 Cronjob。
* `deployment`:          使用指定的名称创建 Deployment。
* `job`:                 使用指定的名称创建 Job。
* `namespace`:           使用指定的名称创建名称空间。
* `poddisruptionbudget`: 使用指定名称创建 Pod 干扰预算。
* `priorityclass`:       使用指定的名称创建 Priorityclass。
* `quota`:               使用指定的名称创建配额。
* `role`:                使用单一规则创建角色。
* `rolebinding`:         为特定角色或 ClusterRole 创建 RoleBinding。
* `secret`:              使用指定的子命令创建 Secret。
* `service`:             使用指定的子命令创建服务。
* `serviceaccount`:      使用指定的名称创建服务帐户。


### `kubectl apply`


* 您可以使用 `kubectl apply` 命令创建或更新资源。有关使用 kubectl apply 更新资源的详细信息，请参阅 [Kubectl 文档](https://kubectl.docs.kubernetes.io)。

