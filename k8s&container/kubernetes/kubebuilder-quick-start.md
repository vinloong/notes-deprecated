



## 安装

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



## 创建一个项目

 创建一个目录，在里面执行 `kubebuilder init` 命令，初始化一个新项目。

```shell

mkdir -p ~/projects/guestbook

cd ~/projects/guestbook

go mod init guestbook/m/v2

kubebuilder init --domain my.domain --repo my.domain/guestbook

#kubebuilder init --domain dragon.io


```



## 创建一个API

运行下面的命令，创建一个新的API ()

```shell
kubebuilder create api --group webapp --version v1 --kind Guestbook
```



## 测试



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









