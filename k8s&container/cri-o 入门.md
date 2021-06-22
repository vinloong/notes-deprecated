

# 安装
 配置前置环境

```shell
# 创建 .conf 文件以在启动时加载模块
cat <<EOF | sudo tee /etc/modules-load.d/crio.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# 配置 sysctl 参数，这些配置在重启之后仍然起作用
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system
```

安装：

| 操作系统 | $OS |
| -------- | ----- |
| Ubuntu 20.04 | `xUbuntu_20.04` |
| Ubuntu 18.04 | `xUbuntu_18.04` |


```shell
OS=xUbuntu_18.04
VERSION=1.20:1.20.0

cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /
EOF
cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list
deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /
EOF

curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers-cri-o.gpg add -

sudo apt-get update
sudo apt-get install cri-o cri-o-runc
```

启动
```shell
sudo systemctl daemon-reload
sudo systemctl enable crio --now
```


默认情况下，CRI-O 使用 systemd cgroup 驱动程序。要切换到 `cgroupfs` 驱动程序，或者编辑 `/ etc / crio / crio.conf` 或放置一个插件 在 `/etc/crio/crio.conf.d/02-cgroup-manager.conf` 中的配置：

```toml
[crio.runtime]
conmon_cgroup = "pod"
cgroup_manager = "cgroupfs"
```
另请注意更改后的 `conmon_cgroup`，将 CRI-O 与 `cgroupfs` 一起使用时， 必须将其设置为 `pod`。通常有必要保持 kubelet 的 cgroup 驱动程序配置 （通常透过 kubeadm 完成）和 CRI-O 一致




