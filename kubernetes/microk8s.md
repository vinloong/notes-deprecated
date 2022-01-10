---
title: microk8s 入门
author: Uncle Dragon
date: 2021-07-02
categories: 
tags: [k8s]
---

<div align='center' ><b><font size='70'> microk8s 入门 </font></b></div>























<center> author: Uncle Dragon </center>


<center>   date: 2021-07-02 </center>


<div STYLE="page-break-after: always;"></div>

[TOC]

<div STYLE="page-break-after: always;"></div>


# 安装：

```shell
snap install microk8s --classic --channel=1.21
```

# 配置

## 设置用户组

```shell
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
```



## 设置镜像加速：
```
vi /var/snap/microk8s/current/args/containerd-template.toml
```

```
  sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.1"
...
...

	  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
        endpoint = [
           "https://dr6tjot4.mirror.aliyuncs.com",
           "https://registry-1.docker.io",
        ]

```


## 拉取镜像：

脚本：
pull-images.sh
```bash
#!/bin/bash
  
folder=${1%.*}

if [ x"${folder}" = x ]; then
  echo -e "\033[31m 请指定 *-images.txt 文件 \033[0m"
  exit
fi

echo ""
echo ""

while read line
do
  let count++
  line=$(echo $line)
  if [ x${line} = x ]; then
    echo -e "\033[33m第 ${count} 行为空\033[0m"
    echo
    continue
  fi
  echo ">>>>> 下载第 ${count} 个镜像 ${line} >>>>>"
  microk8s.ctr --namespace k8s.io image pull $line
  echo ">>>>> 完成第 ${count} 个镜像 ${line}的下载 >>>>>"
  echo ""
done < ${1}

```

镜像：
images.txt
```txt
docker.io/nfvpe/multus:v3.4.2
docker.io/metallb/speaker:v0.9.3
docker.io/metallb/controller:v0.9.3
docker.io/kubernetesui/dashboard:v2.0.0
docker.io/kubernetesui/metrics-scraper:v1.0.4
docker.io/traefik:2.3
docker.io/alpine:3.6
docker.io/cdkbot/hostpath-provisioner-amd64:1.0.0
docker.io/cdkbot/registry-amd64:2.6
docker.io/coredns/coredns:1.8.0
docker.io/jaegertracing/jaeger-operator:1.21.3
docker.io/grafana/grafana:6.4.3
docker.io/nvidia/k8s-device-plugin:1.11
docker.io/busybox:1.28.4
docker.io/nginx:latest
docker.io/cdkbot/microbot-amd64
docker.io/buoyantio/emojivoto-emoji-svc:v8
docker.io/buoyantio/emojivoto-voting-svc:v8
docker.io/buoyantio/emojivoto-web:v8
docker.io/calico/cni:v3.13.2
docker.io/calico/pod2daemon-flexvol:v3.13.2
docker.io/calico/node:v3.13.2
docker.io/calico/kube-controllers:v3.13.2
docker.io/istio/examples-bookinfo-details-v1:1.8.0
docker.io/istio/examples-bookinfo-ratings-v1:1.8.0
docker.io/istio/examples-bookinfo-reviews-v1:1.8.0
docker.io/istio/examples-bookinfo-reviews-v2:1.8.0
docker.io/istio/examples-bookinfo-reviews-v3:1.8.0
docker.io/istio/examples-bookinfo-productpage-v1:1.8.0
docker.elastic.co/kibana/kibana-oss:7.4.2
quay.io/coreos/prometheus-operator:v0.34.0
quay.io/coreos/k8s-prometheus-adapter-amd64:v0.5.0
quay.io/coreos/kube-rbac-proxy:v0.4.1
quay.io/coreos/kube-state-metrics:v1.8.0
quay.io/coreos/kube-rbac-proxy:v0.4.1
quay.io/fluentd_elasticsearch/fluentd:v3.1.0
quay.io/fluentd_elasticsearch/elasticsearch:v7.4.3
quay.io/prometheus/alertmanager
quay.io/prometheus/prometheus
quay.io/prometheus/node-exporter:v0.18.1
registry.aliyuncs.com/google_containers/metrics-server-amd64:v0.3.6
registry.aliyuncs.com/google_containers/k8s-dns-kube-dns-amd64:1.14.7
registry.aliyuncs.com/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.7
registry.aliyuncs.com/google_containers/k8s-dns-sidecar-amd64:1.14.7
registry.aliyuncs.com/google_containers/ingress-nginx/controller:v0.47.0
```

执行脚本：

```shell
./pull-images.sh images.txt
```


```shell
microk8s.ctr --namespace k8s.io image tag registry.aliyuncs.com/google_containers/metrics-server-amd64:v0.3.6 k8s.gcr.io/metrics-server-amd64:v0.3.6
microk8s.ctr --namespace k8s.io image tag registry.aliyuncs.com/google_containers/k8s-dns-kube-dns-amd64:1.14.7 gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.7
microk8s.ctr --namespace k8s.io image tag registry.aliyuncs.com/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.7 gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.7
microk8s.ctr --namespace k8s.io image tag registry.aliyuncs.com/google_containers/k8s-dns-sidecar-amd64:1.14.7 gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.7
microk8s.ctr --namespace k8s.io image tag registry.aliyuncs.com/google_containers/ingress-nginx/controller:v0.47.0 k8s.gcr.io/ingress-nginx/controller:v0.47.0
```
## 完成
等待k8s 初始化完成

```shell
$ microk8s status --wait-ready
microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
addons:
  enabled:
    ha-cluster           # Configure high availability on the current node
  disabled:
    ambassador           # Ambassador API Gateway and Ingress
    cilium               # SDN, fast with full network policy
    dashboard            # The Kubernetes dashboard
    dns                  # CoreDNS
    fluentd              # Elasticsearch-Fluentd-Kibana logging and monitoring
    gpu                  # Automatic enablement of Nvidia CUDA
    helm                 # Helm 2 - the package manager for Kubernetes
    helm3                # Helm 3 - Kubernetes package manager
    host-access          # Allow Pods connecting to Host services smoothly
    ingress              # Ingress controller for external access
    istio                # Core Istio service mesh services
    jaeger               # Kubernetes Jaeger operator with its simple config
    keda                 # Kubernetes-based Event Driven Autoscaling
    knative              # The Knative framework on Kubernetes.
    kubeflow             # Kubeflow for easy ML deployments
    linkerd              # Linkerd is a service mesh for Kubernetes and other frameworks
    metallb              # Loadbalancer for your Kubernetes cluster
    metrics-server       # K8s Metrics Server for API access to service metrics
    multus               # Multus CNI enables attaching multiple network interfaces to pods
    openebs              # OpenEBS is the open-source storage solution for Kubernetes
    openfaas             # openfaas serverless framework
    portainer            # Portainer UI for your Kubernetes cluster
    prometheus           # Prometheus operator for monitoring and logging
    rbac                 # Role-Based Access Control for authorisation
    registry             # Private image registry exposed on localhost:32000
    storage              # Storage class; allocates storage from host directory
    traefik              # traefik Ingress controller for external access

```

访问 k8s
```shell
$ microk8s kubectl get nodes
NAME       STATUS   ROLES    AGE   VERSION
cloud-n1   Ready    <none>   21h   v1.21.1-3+ba118484dd39df
```

```
alias kubectl='microk8s kubectl'
```

---

我把镜像全部导出来了，大家把镜像压缩文件拷贝到自己本地，执行下面脚本就可以了

`import.sh`

```bash
#!/bin/bash

dir=microk8s-images

tar zxvf ${dir}.tar.gz

cd ${dir}

images=$(ls ./*.tar )

for image in ${images}
do
    echo "加载镜像： ${image}"
    microk8s.ctr --namespace k8s.io image import ${image}
    echo "加载完成"
done

```

```shell
./import.sh
```


# 获得k8s 依赖镜像

```shell
$ git clone https://github.com/ubuntu/microk8s.git
Cloning into 'microk8s'...
remote: Enumerating objects: 8514, done.
remote: Counting objects: 100% (847/847), done.
remote: Compressing objects: 100% (473/473), done.
remote: Total 8514 (delta 502), reused 662 (delta 364), pack-reused 7667
Receiving objects: 100% (8514/8514), 12.02 MiB | 7.93 MiB/s, done.
Resolving deltas: 100% (5628/5628), done.

$ grep -ir 'image: ' * | awk '{print $3 $4}' | uniq
nvidia/k8s-device-plugin:1.11
metallb/speaker:v0.9.3
metallb/controller:v0.9.3
cdkbot/hostpath-provisioner-$ARCH:1.0.0
coredns/coredns:1.8.0
image:k8s.gcr.io/ingress-nginx/controller:$TAG
image:traefik:2.3
cdkbot/registry-$ARCH:2.6
quay.io/prometheus/alertmanager
quay.io/coreos/prometheus-operator:v0.34.0

image:grafana/grafana:6.4.3
quay.io/coreos/kube-rbac-proxy:v0.4.1
quay.io/coreos/kube-state-metrics:v1.8.0
quay.io/prometheus/node-exporter:v0.18.1
quay.io/coreos/kube-rbac-proxy:v0.4.1
quay.io/coreos/k8s-prometheus-adapter-amd64:v0.5.0
quay.io/prometheus/prometheus
image:nginx
nfvpe/multus:v3.4.2
kubernetesui/dashboard:v2.2.0
kubernetesui/metrics-scraper:v1.0.6
docker.elastic.co/kibana/kibana-oss:7.10.2
image:quay.io/fluentd_elasticsearch/elasticsearch:v7.10.2
image:alpine:3.6
quay.io/fluentd_elasticsearch/fluentd:v3.1.0

jaegertracing/jaeger-operator:1.24.0
k8s.gcr.io/metrics-server/metrics-server:v0.5.0
gcr.io/google_containers/k8s-dns-kube-dns-$ARCH:1.14.7
gcr.io/google_containers/k8s-dns-dnsmasq-nanny-$ARCH:1.14.7
gcr.io/google_containers/k8s-dns-sidecar-$ARCH:1.14.7
buoyantio/emojivoto-emoji-svc:v8
buoyantio/emojivoto-voting-svc:v8
buoyantio/emojivoto-web:v8
k8s.gcr.io/cuda-vector-add:v0.1
image:cdkbot/microbot-$ARCH
busybox
nginx
localhost:32000/my-busybox
busybox
busybox:1.28.4
image:gcr.io/knative-samples/helloworld-go
nginx:latest
k8s.gcr.io/cuda-vector-add:v0.1
image:cdkbot/microbot-{{
docker.io/calico/cni:v3.19.1
docker.io/calico/pod2daemon-flexvol:v3.19.1
docker.io/calico/node:v3.19.1
docker.io/calico/kube-controllers:v3.17.3
cdkbot/calico-cni-s390x:v3.15.1
cdkbot/calico-pod2daemon-flexvol-s390x:v3.15.1
cdkbot/calico-node-s390x:v3.15.1
cdkbot/calico-kube-controllers-s390x:v3.15.1
```

分析：

```
# 下面几个镜像是无法直接 pull 的
gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.7
gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.7
gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.7
k8s.gcr.io/metrics-server/metrics-server:v0.5.0
k8s.gcr.io/ingress-nginx/controller:v1.0.4
k8s.gcr.io/pause:3.1

# 下面是可以直接 pull 的
docker.io/kubernetesui/dashboard:v2.2.0
docker.io/kubernetesui/metrics-scraper:v1.0.6
docker.io/cdkbot/calico-cni-s390x:v3.15.1
docker.io/cdkbot/calico-pod2daemon-flexvol-s390x:v3.15.1
docker.io/cdkbot/calico-node-s390x:v3.15.1
docker.io/cdkbot/calico-kube-controllers-s390x:v3.15.1
docker.io/cdkbot/hostpath-provisioner-amd64:1.0.0
docker.io/cdkbot/registry-amd64:2.6
docker.io/coredns/coredns:1.8.0
docker.io/calico/cni:v3.19.1
docker.io/calico/pod2daemon-flexvol:v3.19.1
docker.io/calico/node:v3.19.1
docker.io/calico/kube-controllers:v3.17.3
docker.io/grafana/grafana:6.4.3
docker.elastic.co/kibana/kibana-oss:7.10.2
quay.io/fluentd_elasticsearch/elasticsearch:v7.10.2
quay.io/fluentd_elasticsearch/fluentd:v3.1.0
quay.io/prometheus/alertmanager:latest
quay.io/prometheus/prometheus:latest
quay.io/prometheus/node-exporter:v0.18.1
quay.io/coreos/kube-rbac-proxy:v0.4.1
quay.io/coreos/prometheus-operator:v0.34.0
quay.io/coreos/kube-rbac-proxy:v0.4.1
quay.io/coreos/kube-state-metrics:v1.8.0
quay.io/coreos/k8s-prometheus-adapter-amd64:v0.5.0

#
# 下面镜像不是必须的
#

# 一个微服务框架 example
buoyantio/emojivoto-emoji-svc:v8
buoyantio/emojivoto-voting-svc:v8
buoyantio/emojivoto-web:v8

# 微服务治理
jaegertracing/jaeger-operator:1.24.0
traefik:2.3

# AI 智能小车
cdkbot/microbot-amd64

# CPU与GPU并用的“协同处理”
k8s.gcr.io/cuda-vector-add:v0.1

# 机器学习
nvidia/k8s-device-plugin:1.11
metallb/speaker:v0.9.3
metallb/controller:v0.9.3
```



`pull-gcr.sh`

pull  谷歌镜像

```shell
#!/bin/bash
images=(
k8s.gcr.io/metrics-server/metrics-server:v0.5.0=registry.cn-hangzhou.aliyuncs.com/gcr_k8s_containers/microk8s_metrics-server:v0.5.0
gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.7=registry.cn-hangzhou.aliyuncs.com/gcr_k8s_containers/microk8s_dns-sidecar:1.14.7
gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.7=registry.cn-hangzhou.aliyuncs.com/gcr_k8s_containers/microk8s_kube-dns:1.14.7
gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.7=registry.cn-hangzhou.aliyuncs.com/gcr_k8s_containers/microk8s_dnsmasq-nanny:1.14.7
k8s.gcr.io/ingress-nginx/controller:v1.0.4=registry.cn-hangzhou.aliyuncs.com/gcr_k8s_containers/ingress-nginx-controller:v1.0.4
k8s.gcr.io/pause:3.1=registry.cn-hangzhou.aliyuncs.com/gcr_k8s_containers/pause:3.1
)

OIFS=$IFS

for image in ${images[@]};do
    IFS='='
    set $image
    echo -e "\033[32m >>>>>>>> pull $1 ... >>>>>>>> \033[0m"
    microk8s.ctr --namespace k8s.io image pull $2
    microk8s.ctr --namespace k8s.io image tag $2 $1
    IFS=$OIFS
    echo -e "\033[32m ========= pull $1 done. ======== \033[0m"
done
```



`pull.sh`

```shell
#!/bin/bash

images=(
docker.io/kubernetesui/dashboard:v2.2.0
docker.io/kubernetesui/metrics-scraper:v1.0.6
docker.io/cdkbot/calico-cni-s390x:v3.15.1
docker.io/cdkbot/calico-pod2daemon-flexvol-s390x:v3.15.1
docker.io/cdkbot/calico-node-s390x:v3.15.1
docker.io/cdkbot/calico-kube-controllers-s390x:v3.15.1
docker.io/cdkbot/hostpath-provisioner-amd64:1.0.0
docker.io/cdkbot/registry-amd64:2.6
docker.io/coredns/coredns:1.8.0
docker.io/grafana/grafana:6.4.3
docker.io/calico/cni:v3.19.1
docker.io/calico/pod2daemon-flexvol:v3.19.1
docker.io/calico/node:v3.19.1
docker.io/calico/kube-controllers:v3.17.3
docker.elastic.co/kibana/kibana-oss:7.10.2
quay.io/fluentd_elasticsearch/elasticsearch:v7.10.2
quay.io/fluentd_elasticsearch/fluentd:v3.1.0
quay.io/prometheus/alertmanager:latest
quay.io/prometheus/prometheus:latest
quay.io/prometheus/node-exporter:v0.18.1
quay.io/coreos/kube-rbac-proxy:v0.4.1
quay.io/coreos/prometheus-operator:v0.34.0
quay.io/coreos/kube-rbac-proxy:v0.4.1
quay.io/coreos/kube-state-metrics:v1.8.0
quay.io/coreos/k8s-prometheus-adapter-amd64:v0.5.0
)

OIFS=$IFS

for image in ${images[@]};do
    echo -e "\033[32m >>>>>>>>>>>>>> pull ${image} >>>>>>>>>>>>>>> \033[0m"
    microk8s.ctr --namespace k8s.io image pull $image
    echo -e "\033[32m ============== pull ${image} done. ============== \033[0m"
done

```







# 配置

microk8s containerd 的配置在 `/var/snap/microk8s/current/args/`

