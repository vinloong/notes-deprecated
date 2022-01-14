```
# 必要
k8s.gcr.io/kube-apiserver:v1.18.20
k8s.gcr.io/kube-controller-manager:v1.18.20
k8s.gcr.io/kube-scheduler:v1.18.20
k8s.gcr.io/kube-proxy:v1.18.20
k8s.gcr.io/pause:3.2
k8s.gcr.io/etcd:3.4.3-0
k8s.gcr.io/coredns:1.6.7
docker.io/calico/cni:v3.19.1
docker.io/calico/kube-controllers:v3.17.3
k8s.gcr.io/ingress-nginx/controller:1.0.0
k8s.gcr.io/metrics-server/metrics-server:v0.5.0

# 可选
gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.7
gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.7
gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.7
coredns/coredns:1.8.0
docker.io/calico/pod2daemon-flexvol:v3.19.1
docker.io/calico/node:v3.19.1
quay.io/coreos/kube-rbac-proxy:v0.4.1
quay.io/coreos/kube-state-metrics:v1.8.0
quay.io/coreos/kube-rbac-proxy:v0.4.1
nfvpe/multus:v3.4.2


# microk8s
cdkbot/microbot-amd64
kubernetesui/dashboard:v2.2.0
k8s.gcr.io/ingress-nginx/controller:1.0.0
coredns/coredns:1.8.0
docker.io/calico/cni:v3.19.1
docker.io/calico/node:v3.19.1
docker.io/calico/kube-controllers:v3.17.3


# 基础镜像
alpine:3.6
busybox:1.28.4


#日志
quay.io/fluentd_elasticsearch/elasticsearch:v7.10.2
quay.io/fluentd_elasticsearch/fluentd:v3.1.0
docker.elastic.co/kibana/kibana-oss:7.10.2

# 监控
jaegertracing/jaeger-operator:1.24.0
grafana/grafana:6.4.3
quay.io/prometheus/node-exporter:v0.18.1
quay.io/coreos/k8s-prometheus-adapter-amd64:v0.5.0
quay.io/coreos/prometheus-operator:v0.34.0
```
