

```shell
kubectl label node {node-name} node-role.kubernetes.io/worker=worker

# 给节点添加 标签
kubectl label nodes <node-name> <label-key>=<label-value> 

# 删除 节点 标签
kubectl label nodes <node-name> <label-key>-

# 重新 给节点 打标签
kubectl label nodes <node-name> <label-key>=<label-value> --overwrite
```


k8s 查看 pod/node 列出标签需要使用 `--show-labels` 选项

```shell

kubectl get pod --show-labels

kubectl get node --show-labels

```


指定标签查看

```shell


kubectl get po -L app.kubernetes.io/name


kubectl get no -l ceph-mon=enabled


kubectl get po -n savoir  -L app

```


