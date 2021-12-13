

[TOC]



# 安装

linux/mac 

```shell


# 我使用的版本是 v3.1.0
VERSION=v3.1.0

# 到 https://github.com/kubernetes-sigs/kubebuilder/releases 下载与你操作系统对应的 kubebuilder 安装包
wget https://github.com/kubernetes-sigs/kubebuilder/releases/download/$(VERSION)/kubebuilder_$(go env GOOS)_$(go env GOARCH) -O kubebuilder
# 或使用下面命令下载
curl -L -o kubebuilder https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)

# 解压到 /usr/local/bin/
# 解压到这里不用自己添加环境变量，如果是自定义的目录，还需要将其加入到环境变量 path 中
chmod +x kubebuilder && mv kubebuilder /usr/local/bin/

```

windows 

```cmd
# windows 下没有对应的安装包，需要自己把代码下下来，自己编译
# 由于windows 版本没有脚本在创建api的时候会报错，所以建议还是使用linux 版本
git clone git@github.com:kubernetes-sigs/kubebuilder
cd kubebuilder
go build -o kubebuilder.exe ./cmd/


```



# 创建一个项目

 创建一个目录，在里面执行 `kubebuilder init` 命令，初始化一个新项目。

```shell

mkdir -p ~/projects/guestbook

cd ~/projects/guestbook

go mod init guestbook/m/v2

kubebuilder init --domain my.domain --repo my.domain/guestbook

#kubebuilder init --domain dragon.io

```

## 一个基础项目里都有什么？

当脚手架为我们自动生成一个新的项目时，kubebuilder 为我们准备好了一些基础的模板文件。

### 构建基础组件

首先是为构建准备的一些基本的项目文件

- `go.mod` :   Go mod 配置文件，记录依赖库信息

  ```go
  module dragon.com/guestbook
  
  go 1.16
  
  require (
  	github.com/onsi/ginkgo v1.14.1
  	github.com/onsi/gomega v1.10.2
  	k8s.io/apimachinery v0.20.2
  	k8s.io/client-go v0.20.2
  	sigs.k8s.io/controller-runtime v0.8.3
  )
  ```

  

- `Makefile`: 用于构建和部署你的*controller*的 Makefile 文件

  ```cmake
  
  # Image URL to use all building/pushing image targets
  IMG ?= controller:latest
  # Produce CRDs that work back to Kubernetes 1.11 (no version conversion)
  CRD_OPTIONS ?= "crd:trivialVersions=true,preserveUnknownFields=false"
  
  # Get the currently used golang install path (in GOPATH/bin, unless GOBIN is set)
  ifeq (,$(shell go env GOBIN))
  GOBIN=$(shell go env GOPATH)/bin
  else
  GOBIN=$(shell go env GOBIN)
  endif
  
  # Setting SHELL to bash allows bash commands to be executed by recipes.
  # This is a requirement for 'setup-envtest.sh' in the test target.
  # Options are set to exit when a recipe line exits non-zero or a piped command fails.
  SHELL = /usr/bin/env bash -o pipefail
  .SHELLFLAGS = -ec
  
  all: build
  
  ##@ General
  
  # The help target prints out all targets with their descriptions organized
  # beneath their categories. The categories are represented by '##@' and the
  # target descriptions by '##'. The awk commands is responsible for reading the
  # entire set of makefiles included in this invocation, looking for lines of the
  # file as xyz: ## something, and then pretty-format the target and help. Then,
  # if there's a line with ##@ something, that gets pretty-printed as a category.
  # More info on the usage of ANSI control characters for terminal formatting:
  # https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
  # More info on the awk command:
  # http://linuxcommand.org/lc3_adv_awk.php
  
  help: ## Display this help.
  	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
  
  ##@ Development
  
  manifests: controller-gen ## Generate WebhookConfiguration, ClusterRole and CustomResourceDefinition objects.
  	$(CONTROLLER_GEN) $(CRD_OPTIONS) rbac:roleName=manager-role webhook paths="./..." output:crd:artifacts:config=config/crd/bases
  
  generate: controller-gen ## Generate code containing DeepCopy, DeepCopyInto, and DeepCopyObject method implementations.
  	$(CONTROLLER_GEN) object:headerFile="hack/boilerplate.go.txt" paths="./..."
  
  fmt: ## Run go fmt against code.
  	go fmt ./...
  
  vet: ## Run go vet against code.
  	go vet ./...
  
  ENVTEST_ASSETS_DIR=$(shell pwd)/testbin
  test: manifests generate fmt vet ## Run tests.
  	mkdir -p ${ENVTEST_ASSETS_DIR}
  	test -f ${ENVTEST_ASSETS_DIR}/setup-envtest.sh || curl -sSLo ${ENVTEST_ASSETS_DIR}/setup-envtest.sh https://raw.githubusercontent.com/kubernetes-sigs/controller-runtime/v0.8.3/hack/setup-envtest.sh
  	source ${ENVTEST_ASSETS_DIR}/setup-envtest.sh; fetch_envtest_tools $(ENVTEST_ASSETS_DIR); setup_envtest_env $(ENVTEST_ASSETS_DIR); go test ./... -coverprofile cover.out
  
  ##@ Build
  
  build: generate fmt vet ## Build manager binary.
  	go build -o bin/manager main.go
  
  run: manifests generate fmt vet ## Run a controller from your host.
  	go run ./main.go
  
  docker-build: test ## Build docker image with the manager.
  	docker build -t ${IMG} .
  
  docker-push: ## Push docker image with the manager.
  	docker push ${IMG}
  
  ##@ Deployment
  
  install: manifests kustomize ## Install CRDs into the K8s cluster specified in ~/.kube/config.
  	$(KUSTOMIZE) build config/crd | kubectl apply -f -
  
  uninstall: manifests kustomize ## Uninstall CRDs from the K8s cluster specified in ~/.kube/config.
  	$(KUSTOMIZE) build config/crd | kubectl delete -f -
  
  deploy: manifests kustomize ## Deploy controller to the K8s cluster specified in ~/.kube/config.
  	cd config/manager && $(KUSTOMIZE) edit set image controller=${IMG}
  	$(KUSTOMIZE) build config/default | kubectl apply -f -
  
  undeploy: ## Undeploy controller from the K8s cluster specified in ~/.kube/config.
  	$(KUSTOMIZE) build config/default | kubectl delete -f -
  
  
  CONTROLLER_GEN = $(shell pwd)/bin/controller-gen
  controller-gen: ## Download controller-gen locally if necessary.
  	$(call go-get-tool,$(CONTROLLER_GEN),sigs.k8s.io/controller-tools/cmd/controller-gen@v0.4.1)
  
  KUSTOMIZE = $(shell pwd)/bin/kustomize
  kustomize: ## Download kustomize locally if necessary.
  	$(call go-get-tool,$(KUSTOMIZE),sigs.k8s.io/kustomize/kustomize/v3@v3.8.7)
  
  # go-get-tool will 'go get' any package $2 and install it to $1.
  PROJECT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
  define go-get-tool
  @[ -f $(1) ] || { \
  set -e ;\
  TMP_DIR=$$(mktemp -d) ;\
  cd $$TMP_DIR ;\
  go mod init tmp ;\
  echo "Downloading $(2)" ;\
  GOBIN=$(PROJECT_DIR)/bin go get $(2) ;\
  rm -rf $$TMP_DIR ;\
  }
  endef
  ```

  

- `PROJECT`:  用于生成组件的 Kubebuilder 元数据

  ```yaml
  domain: dragon.com
  layout:
  - go.kubebuilder.io/v3
  projectName: guestbook
  repo: dragon.com/guestbook
  resources:
  - api:
      crdVersion: v1
      namespaced: true
    controller: true
    domain: dragon.com
    group: webapp
    kind: Guestbook
    path: dragon.com/guestbook/api/v1
    version: v1
  version: "3"
  
  ```

  

### 启动配置

我们还可以在 *`config/`* 目录下获得启动配置。现在，它只包含了在集群上启动控制器所需的 *`Kustomize`* YAML 配置中定义，但一旦我们开始编写控制器，它还将包含我们的 CustomResourceDefinitions(CRD) 、RBAC 配置和 WebhookConfigurations 。

*`config/default`* 中包含` Kustomize base`用于启动`controller` 的一些标准配置。

其他每个目录都包含一个不同的配置，重构为自己的基础。

- *`config/manager`*: 在集群中以 pod 的形式启动`controller`
- *`config/rbac`*: 在自己的账户下运行`controller`所需的权限



### 程序入口

最后，最重要的一点，`kubebuilder` 生成一个项目程序入口: `main.go`，接下来我们来看看它。。。

 

### 任何一段旅程都需要一个起点，每一个程序都需要一个入口函数



main 文件开始是 import 一些基本库, 尤其是

- 核心控制器运行时库
- 默认的控制器运行时日志库 --- zap

```go
import (
	webappv1 "dragon.com/guestbook/api/v1"
	"dragon.com/guestbook/controllers"
	"flag"
	"k8s.io/apimachinery/pkg/runtime"
	utilruntime "k8s.io/apimachinery/pkg/util/runtime"
	clientgoscheme "k8s.io/client-go/kubernetes/scheme"
	_ "k8s.io/client-go/plugin/pkg/client/auth"
	"os"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/healthz"
	"sigs.k8s.io/controller-runtime/pkg/log/zap"
	//+kubebuilder:scaffold:imports
)
```

每一组控制器都需要一个 *Scheme*，它提供了 Kinds 和相应的 Go 类型之间的映射。我们将在编写 API 定义的时候再谈一谈 Kinds，所以现在只需要记住它就好。

```go
var (
	scheme   = runtime.NewScheme()
	setupLog = ctrl.Log.WithName("setup")
)

func init() {
	utilruntime.Must(clientgoscheme.AddToScheme(scheme))

	utilruntime.Must(webappv1.AddToScheme(scheme))
	//+kubebuilder:scaffold:scheme
}
```



这段代码的核心逻辑比较简单：

- 我们通过 flag 库解析入参
- 我们实例化一个 manager ,它记录了我们所有控制器的运行情况，以及设置共享缓存和API 服务器的客户端，（注意，我们把我们的 Scheme 的信息告诉了 manager）
- 运行 manager ，它反过来运行我们所有的控制器和 webhooks 。mangager 状态被设置为 Runing ，直到它收到一个优雅的停机信号，这样我们就可以在k8s 上运行时app时，可以优雅的停止pod.



现在我们还没运行任何代码，但是请记住这个注释 `//+kubebuilder:scaffold:scheme`

```go
func main() {
	var metricsAddr string
	var enableLeaderElection bool
	var probeAddr string
	flag.StringVar(&metricsAddr, "metrics-bind-address", ":8080", "The address the metric endpoint binds to.")
	flag.StringVar(&probeAddr, "health-probe-bind-address", ":8081", "The address the probe endpoint binds to.")
	flag.BoolVar(&enableLeaderElection, "leader-elect", false,
		"Enable leader election for controller manager. "+
			"Enabling this will ensure there is only one active controller manager.")
	opts := zap.Options{
		Development: true,
	}
	opts.BindFlags(flag.CommandLine)
	flag.Parse()

	ctrl.SetLogger(zap.New(zap.UseFlagOptions(&opts)))

	mgr, err := ctrl.NewManager(ctrl.GetConfigOrDie(), ctrl.Options{
		Scheme:                 scheme,
		MetricsBindAddress:     metricsAddr,
		Port:                   9443,
		HealthProbeBindAddress: probeAddr,
		LeaderElection:         enableLeaderElection,
		LeaderElectionID:       "bcb35137.dragon.com",
	})
	if err != nil {
		setupLog.Error(err, "unable to start manager")
		os.Exit(1)
	}

	if err = (&controllers.GuestbookReconciler{
		Client: mgr.GetClient(),
		Scheme: mgr.GetScheme(),
	}).SetupWithManager(mgr); err != nil {
		setupLog.Error(err, "unable to create controller", "controller", "Guestbook")
		os.Exit(1)
	}
	//+kubebuilder:scaffold:builder

	if err := mgr.AddHealthzCheck("healthz", healthz.Ping); err != nil {
		setupLog.Error(err, "unable to set up health check")
		os.Exit(1)
	}
	if err := mgr.AddReadyzCheck("readyz", healthz.Ping); err != nil {
		setupLog.Error(err, "unable to set up ready check")
		os.Exit(1)
	}

	setupLog.Info("starting manager")
	if err := mgr.Start(ctrl.SetupSignalHandler()); err != nil {
		setupLog.Error(err, "problem running manager")
		os.Exit(1)
	}
}
```

注意：Manager 可以通过以下方式限制控制器可以监听资源的命名空间：

```go
	mgr, err := ctrl.NewManager(ctrl.GetConfigOrDie(), ctrl.Options{
		Scheme:                 scheme,
        Namespace:          namespace,
		MetricsBindAddress:     metricsAddr,
		Port:                   9443,
		HealthProbeBindAddress: probeAddr,
		LeaderElection:         enableLeaderElection,
		LeaderElectionID:       "bcb35137.dragon.com",
	})
```

上面的栗子把你的项目改成了只监听单一命名空间。在这种情况下，建议通过默认的 ClusterRole 和 ClusterRoleBinding 分别替换为 Role 和 RoleBinding 来限制所提供给这个命名空间的授权。



另外，也可以使用 MultiNamespacedCacheBuilder 来监听特定的命名空间。

```go
   var namespaces []string // List of Namespaces

    mgr, err = ctrl.NewManager(ctrl.GetConfigOrDie(), ctrl.Options{
        Scheme:             scheme,
        NewCache:           cache.MultiNamespacedCacheBuilder(namespaces),
        MetricsBindAddress: fmt.Sprintf("%s:%d", metricsHost, metricsPort),
    })
```



说完这些，我们可以开始创建我们的 API 了。



# GVK 介绍

在我们开始说 API 之前，我们应该先介绍下 k8s 中 API 的相关术语

我们在谈论 k8s 的API 我们经常会提到 下面4个术语： groups 、versions 、kinds 和 resources 。

## 组和版本

k8s 中的API 组简单来说就是相关功能的集合。每个组都有一个或多个版本，顾名思义，它允许我们随这时间的推移改变 API 的职责。

## 类型和资源

每个API 组-版本包含一个或多个API 类型，我们称之为 Kinds。 虽然一个 Kind 可以在不同版本之间改变表单内容, 但每个表单必须能够以某种方式存储其他表单的所有数据(我们可以把数据存储在字段中或者在注释中)。这样在使用旧版的API 版本不会导致新的数据丢失或损失。



你也会偶尔听到 `resources`。 `resources` (资源) 只是API 中的一个kind 的使用方式。通常情况下，Kind 和 resource 之间有一个一对一的映射。例如，`pods` 资源对应于 `Pod` 种类。但是有时，同一类型可能由多个资源返回。例如，`Scale` Kind 是由所有 `scale` 子资源返回的，如 `deployments/scale` 或 `replicasets/scale`。这就是允许 Kubernetes HorizontalPodAutoscaler(HPA) 与不同资源交互的原因。然而，使用 CRD，每个 Kind 都将对应一个 resources。



注意：resource 总是小写，按照惯例是 kind 的小写形式。



```
GVK = Group Version Kind GVR = Group Version Resources
```

当我们在一个特定的群组版本 (Group-Version) 中提到一个 Kind 时，我们会把它称为 **GroupVersionKind**，简称 GVK。与 资源 (resources) 和 GVR 一样，我们很快就会看到，每个 GVK 对应 Golang 代码中的到对应生成代码中的 Go type。

现在我们理解了这些术语，我们就可以**真正**地创建我们的 API！



## Scheme 是什么？

我们之前看到的 `Scheme` 是一种追踪 Go Type 的方法，它对应于给定的GVK.

例如，假如我们将 `"tutorial.kubebuilder.io/api/v1".Guestbook{}` 类型放置在 `batch.tutorial.kubebuilder.io/v1` API 组中（也就是说它有 `Guestbook` Kind)。

然后，我们便可以在 API server 给定的 json 数据构造一个新的 `&Guestbook{}`。

```go
{
    "kind": "Guestbook",
    "apiVersion": "batch.tutorial.kubebuilder.io/v1",
    ...
}
```

或当我们在一次变更中去更新或提交 `&Guestbook{}` 时，查找正确的组版本



# 创建一个API

搭建一个新的 kind ,和相应的控制器，创建一个新的API  ,我们可以使用kubebuilder create api :

```shell
 kubebuilder create api --group webapp --version v1 --kind Guestbook
```

当我们第一次为每个组-版本使用这个命令的时候，它会自动创建一个新的组-版本目录。

本案例中创建了一个对应 `dragon.com/v1`的目录 `api/v1`

它也为我们的 `Guestbook` Kind 添加了一个文件, `api/v1/guestbook_types.go`。每次我们用不同的 kind 去调用这个命令，它将添加一个相应的新文件。

我们来看下有哪些东西：

```shell
vi guestbook_types.go
```

导入 meta/v1 API 组,通常本身并不会暴露该组，而是包含所有 k8s 种类共有的元数据。

```go
import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)
```

下面，我们为种类的 `Spec`  和 `Status` 定义类型。 k8s 功能通过使期待的状态 (Spec) 和实际集群状态(其他对象的 `Status` )保持一致和外部状态，然后记录观察到的状态(Status)。 因此，每个 `functional` 对象包括 `spec` 和 `status` 。 很少的类型，像 `ConfiMap` 不需要遵从这个模式，因此它们不编码期待的状态，但是大部分类型需要做这一步。

 

```go
// 编辑这个文件！这个是你拥有的脚手架
// 注意的是：json 标签是必需的.为了能够序列化字段，任何你添加的新字段一定要有 json 标签。

// GuestbookSpec defines the desired state of Guestbook
type GuestbookSpec struct {
	// INSERT ADDITIONAL SPEC FIELDS - desired state of cluster
	// Important: Run "make" to regenerate code after modifying this file

	// Foo is an example field of Guestbook. Edit guestbook_types.go to remove/update
	Foo string `json:"foo,omitempty"`
	metav1.TypeMeta `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec v1beta1.CronJobSpec	`json:"spec,omitempty"`
	Status v1beta1.CronJobStatus	`json:"status,omitempty"`
}

// GuestbookStatus defines the observed state of Guestbook
type GuestbookStatus struct {
	// INSERT ADDITIONAL STATUS FIELD - define observed state of cluster
	// Important: Run "make" to regenerate code after modifying this file

}
```

下一步，我们定义与实际种类相对应的类型，`Guestbook` 和 `GuestbookList` 。`Guestbook` 是一个根类型，它描述了 `Guestbook`种类。像所有 k8s 对象，它包含 `TypeMeta` (描述了 API 版本和种类),也包含其中拥有像名称，名称空间和标签的东西的 `ObjectMeta`。
`GuestbookList` 只是多个 `Guestbook` 的容器，它是批量操作中使用的种类，像 List 。

通常情况下，我们从不修改任何一个 -- 所有修改都要到 `Spec` 或者 `Status`。

那个小小的 `+kubebuilder:object:root` 注释被称为标记。我们将会看到更多的它们，但要知道它们充当额外的元数据，告诉 `controller-root` (我们的代码和YAML生成器)额外的信息。这个特定的标签告诉 `object` 生成器这个类型表示一个种类。然后，`object`生成器为我们生成这个所有表示种类的类型一定要实现的 `runtime.Object` 接口的实现。


# 测试


将 CRD 安装到集群中

```bash
make install
```

运行控制器（这将在前台运行，如果你想让它一直运行，请切换到新的终端）。

```bash
make run
```



## 安装 CR 实例

如果你按了 `y` 创建资源 [y/n]，那么你就为示例中的自定义资源定义 `CRD` 创建了一个自定义资源 `CR` （如果你更改了 API 定义，请务必先编辑它们）。

```bash
kubectl apply -f config/samples/
```



## 如何在集群中运行

构建并推送你的镜像到 你指定的镜像仓库

```bash
make docker-build docker-push IMG=<your-registry>/<project-name>:tag
```

根据 IMG 指定的镜像将控制器部署到集群中

```bash
make deploy IMG=<your-registry>/<project-name>:tag
