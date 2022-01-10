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
#     echo "======================== pull ${image} ================================"
    echo -e "\033[32m >>>>>>>>>>>>>> pull ${image} >>>>>>>>>>>>>>> \033[0m"
    microk8s.ctr --namespace k8s.io image pull $image
    echo -e "\033[32m ============== pull ${image} done. ============== \033[0m"
#    echo "======================== ${image} ====================================="
done
