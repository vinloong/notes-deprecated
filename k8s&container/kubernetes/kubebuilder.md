



# [Installation](https://book.kubebuilder.io/quick-start.html#installation)

linux/mac 

```shell
# 到 https://github.com/kubernetes-sigs/kubebuilder/releases 下载与你操作系统对应的 kubebuilder 安装包
# 解压到 /usr/local/bin/
# 版本是 v3.1.0
VERSION=v3.1.0
wget https://github.com/kubernetes-sigs/kubebuilder/releases/download/$(VERSION)/kubebuilder_$(go env GOOS)_$(go env GOARCH) -O kubebuilder
chmod +x kubebuilder && mv kubebuilder /usr/local/bin/

# 或

# download kubebuilder and install locally.
curl -L -o kubebuilder https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)
chmod +x kubebuilder && mv kubebuilder /usr/local/bin/

```

windows 

```cmd
# windows 下 没有对应的安装包，需要自己把代码下下来，自己编译
git clone git@github.com:kubernetes-sigs/kubebuilder
cd kubebuilder
go build -o kubebuilder.exe ./cmd/
```



# [Create a Project](https://book.kubebuilder.io/quick-start.html#create-a-project)

```shell
mkdir -p ~/projects/guestbook

cd ~/projects/guestbook

go mod init guestbook/m/v2

kubebuilder init --domain my.domain --repo my.domain/guestbook

#kubebuilder init --domain dragon.io

kubebuilder create api --group webapp --version v1 --kind Guestbook
```

