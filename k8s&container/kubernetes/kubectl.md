

kubectl 是一个管理k8s集群的命令行工具.

kubectl 在``$HOME/.kube` 目录中有一个名为'config'的配置文件

你可以通过设置 KUBECONFIG 环境变量或设置 `--kubeconfig`来指定其他 kuebconfig 文件。



语法：

```shell
kubectl [command] [TYPE] [NAME] [flags]
```

>- `command` : 指定要对一个或多个资源执行的操作，比如： create 、get 、describe 、delete
>- `TYPE`        :  指定资源类型. 这里资源类型不区分大小写，可以指定单数、复数或缩写形式
>- `NAME`        :  指定资源名称。资源名称是区分大小写的，如果省略名称，则显示所有资源的详细信息
>- `flags`      :  指定可选的参数，比如：可以使用 `-s` 或 `-server` 参数来指定 k8s api 服务器的地址和端口

```shell
# 栗子：

# TYPE 下面三个命令输出结果相同
kubectl get pod 
kubectl get pods
kubectl get po

# NAME :
# 按类型和名称指定资源
# 要对所有类型相同的资源进行分组，请执行以下操作：TYPE1 name1 name2 name<#>
kubectl get pod example-pod1 example-pod2
# 分别指定多个资源类型：TYPE1/name1 TYPE1/name2 TYPE2/name3 TYPE<#>/name<#>
kubectl get pod/example-pod1 replicationcontroller/example-rc1
# 用一个或多个文件指定资源：-f file1 -f file2 -f file<#>
# 使用 YAML 而不是 JSON 因为 YAML 更容易使用，特别是用于配置文件时
kubectl get -f ./pod.yaml
```



**从命令行指定的参数会覆盖默认值和任何相应的环境变量**