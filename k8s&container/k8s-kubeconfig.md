使用 kubeconfig 文件来组织有关集群、用户、命名空间和身份认证机制的信息。`kubectl` 命令行工具使用 kubeconfig 文件来查找选择集群所需的信息，并与集群的 API 服务器进行通信。



默认情况下，`kubectl` 在 `$HOME/.kube` 目录下查找名为 `config` 的文件。 您可以通过设置 `KUBECONFIG` 环境变量或者设置 `--kubeconfig`参数来指定其他 kubeconfig 文件。



```shell
kubectl config view

```





```shell

kubectl config use-context

```






```shell
#  创建命名空间 devops
# $ kubectl create namespace devops
# namespace/devops created


# 在命名空间 devops 下创建 k8s-dashboard-admin 用户
$ kubectl create sa k8s-dashboard-admin -n kube-system
serviceaccount/k8s-dashboard-admin created


# 查看 集群角色 cluster-admin 这个角色具有所有权限
$kubectl get clusterrole
NAME                                                                   CREATED AT
calico-kube-controllers                                                2021-08-09T02:50:10Z
calico-node                                                            2021-08-09T02:50:10Z
coredns                                                                2021-08-09T03:25:13Z
system:aggregated-metrics-reader                                       2021-08-09T03:27:02Z
system:metrics-server                                                  2021-08-09T03:27:03Z
cluster-admin                                                          2021-08-09T03:28:17Z
system:discovery                                                       2021-08-09T03:28:17Z
system:monitoring                                                      2021-08-09T03:28:17Z
system:basic-user                                                      2021-08-09T03:28:17Z
... ...
... ...


# 在 devops 命名空间下创建一个角色绑定 k8s-dashboard-admin-rolebinding ，绑定 cluster-admin ，赋予 devops 下 k8s-dashboard-admin cluster-admin 的所有权限
$ kubectl create rolebinding k8s-dashboard-admin-rolebinding -n kube-system --clusterrole=cluster-admin --serviceaccount=kube-system:k8s-dashboard-admin
rolebinding.rbac.authorization.k8s.io/k8s-dashboard-admin-rolebinding created


# 查看 devops 名称空间下 secret 
$ kubectl get secret -n kube-system
NAME                              TYPE                                  DATA   AGE
default-token-s4zf6               kubernetes.io/service-account-token   3      5m33s
k8s-dashboard-admin-token-5df6v   kubernetes.io/service-account-token   3      4m42s


# 查看 k8s-dashboard-admin-token-5df6v 这个 secret 的详细信息，以及对应的token
$ kubectl describe secret k8s-dashboard-admin-token-5df6v -n kube-system
Name:         k8s-dashboard-admin-token-5df6v
Namespace:    devops
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: k8s-dashboard-admin
              kubernetes.io/service-account.uid: a7a32093-1215-4d06-9ab4-dddd2cd31b2d

Type:  kubernetes.io/service-account-token

Data
====
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6InFvYVB3N05FbjUwRDJWRm5oXzJxOE1RRHB0dmN2b0N5MkYzRHhQUW55RXcifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZXZvcHMiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoiazhzLWRhc2hib2FyZC1hZG1pbi10b2tlbi01ZGY2diIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJrOHMtZGFzaGJvYXJkLWFkbWluIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiYTdhMzIwOTMtMTIxNS00ZDA2LTlhYjQtZGRkZDJjZDMxYjJkIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRldm9wczprOHMtZGFzaGJvYXJkLWFkbWluIn0.epzryCp4kgAWsHifUrFGj4SSxrFksBw8NyghC_y7uZ07PaYFakZuyKxgyqi12FYcAMfXmFtbMWM_Fu7WFI6uQRZKkF4ruiqyLOqrXjrc0kjHx0Cn8NoquuAXjvMpme2c-FZ4SOBxtKJ3I40r04nkXFNQAgvgrAvInKvQqEcEhYuVqR0MwWYCCy2k87O8lOV9wBWgX5EN7_-SKSWbKsaG3aF_rEOxJF3oUBvxzzoKrqjRuavs7r8e4TQp6-Q8QNBrQ1i7TR1Ud93eWH1BYK_8rxakK8AHny1BFLWBfIsBiuH112-6yKygg_dDL6yy8btLwQxeRbbQCe7p_4633YGC_g
ca.crt:     1123 bytes
namespace:  6 bytes

```





```shell
$ kubectl config set-cluster microk8s-local --embed-certs --certificate-authority=/var/snap/microk8s/current/certs/ca.crt --server=https://127.0.0.1:16443 --kubeconfig=./dashboard.conf
Cluster "microk8s-local" set.

$ kubectl config set-credentials k8s-dashboard-admin --token=$KD_TOKEN --kubeconfig=./dashboard.conf
User "k8s-dashboard-admin" set.

$ kubectl config set-context k8s-dashboard --cluster=microk8s-local --user=k8s-dashboard-admin --namespace=kube-system --kubeconfig=./dashboard.conf
Context "k8s-dashboard" created.

$ kubectl config use-context k8s-dashboard --kubeconfig=./dashboard.conf
Switched to context "k8s-dashboard".
```







































