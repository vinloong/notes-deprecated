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
