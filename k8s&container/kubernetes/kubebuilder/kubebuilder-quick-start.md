



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

 

### 任何一段旅程都需要一个起点，每一个程序都需要一个main





# 创建一个API

运行下面的命令，创建一个新的API ()

```shell
kubebuilder create api --group webapp --version v1 --kind Guestbook
```



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

```
make docker-build docker-push IMG=<your-registry>/<project-name>:tag
```

根据 IMG 指定的镜像将控制器部署到集群中

```
make deploy IMG=<your-registry>/<project-name>:tag
```









