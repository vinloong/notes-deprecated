---
title: k8s 移除节点
date: 2020-09-26
categories: 
    - k8s&docker
tags: [k8s]
---

## k8s 移除节点
```bash
# 查看节点
> kubectl get node
NAME          STATUS   ROLES    AGE    VERSION
test-master   Ready    master   6d1h   v1.14.3
test-n1       Ready    <none>   20h    v1.14.3
test-n2       Ready    <none>   20h    v1.14.3
test-n3       Ready    <none>   23m    v1.14.3
test-n4       Ready    <none>   23m    v1.14.3
test-n5       Ready    <none>   23m    v1.14.3
```

<!--more-->

```bash
# 设置节点`test-n3`不可调度
> kubectl cordon test-n3
node/test-n3 cordoned

# 将节点上资源调度到其他节点
> kubectl drain test-n3 --delete-local-data --force --ignore-daemonsets
node/test-n3 already cordoned
WARNING: ignoring DaemonSet-managed Pods: kube-system/kube-flannel-ds-amd64-2vll2, kube-system/kube-flannel-ds-s66xb, kube-system/kube-proxy-tjpdv
evicting pod "coredns-7d675487d6-kzk5l"
pod/coredns-7d675487d6-kzk5l evicted
node/test-n3 evicted

# 删除节点 `test-n3`
> kubectl delete node test-n3
node "test-n3" deleted

# 恢复调度节点
> kubectl uncordon test-n3
```
##  重置节点

```bash
> kubeadm reset
[reset] WARNING: changes made to this host by 'kubeadm init' or 'kubeadm join' will be reverted. 
[reset] are you sure you want to proceed? [y/N]: y 
[preflight] running pre-flight checks 
[reset] no etcd config found. Assuming external etcd 
[reset] please manually reset etcd to prevent further issues 
[reset] stopping the kubelet service 
[reset] unmounting mounted directories in "/var/lib/kubelet" 
[reset] deleting contents of stateful directories: 
[/var/lib/kubelet /etc/cni/net.d /var/lib/dockershim /var/run/kubernetes] 
[reset] deleting contents of config directories: 
[/etc/kubernetes/manifests /etc/kubernetes/pki] 
[reset] deleting files: 
[/etc/kubernetes/admin.conf /etc/kubernetes/kubelet.conf /etc/kubernetes/bootstrap-kubelet.conf /etc/kubernetes/controller-manager.conf /etc/kubernetes/scheduler.conf]

> systemctl stop kubelet
> rm -rf /var/lib/cni/ && rm -rf /var/lib/kubelet/* && rm -rf /etc/cni/
> ifconfig cni0 down && ifconfig flannel.1 down && ifconfig docker0 down
> ip link delete cni0 && ip link delete flannel.1
> systemctl restart docker
> systemctl start kubelet

```

## k8s 添加节点
```bash
# 获取加入集群命令
> kubeadm token create --print-join-command
```

## k8s 节点加入集群，状态 `not ready`
```bash
> kubectl get po -n kube-system -o wide
# 如果是 `kube-flannel` 无法启动 
# 查看 节点 `/etc/cni/net.d `
> ls /etc/cni/net.d
# 如果没有该路径
scp test-master:/etc/cni/net.d/* /etc/cni/net.d/

```






