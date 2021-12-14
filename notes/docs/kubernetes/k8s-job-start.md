
> 容器按照持续运行的时间可分为两类:服务类容器和工作类容器
> 服务类容器通常持续提供服务,需要一直运行,比如HTTPServer、Daemon等。
> 工作类容器则是一次性任务,比如批处理程序,完成后容器就退出
> Kubernetes的Deployment、ReplicaSet和DaemonSet都用于管理服务类容器;
> 对于工作类容器,我们使用Job

这里

> 下面大家先看一个例子：

```yaml
apiVersion: batch/v1beta1 # 当前Job的apiVersion
kind: CronJob             # 指明当前资源的类型为Job
metadata:
  namespace: anxincloud
  labels:
    app: job-prediction-water-level
  name: job-prediction-water-level
spec:
  concurrencyPolicy: Replace
  jobTemplate:
    metadata:
      labels:
        app: job-prediction-water-level
    spec:
      template:
        spec:
          containers:
            - name: prediction-water-level
              resources:
                requests:
                  cpu: 100m
                  memory: 100Mi
                limits:
                  cpu: '4'
                  memory: 500Mi
              imagePullPolicy: IfNotPresent
              image: prediction-water-level[:tag]
              envFrom:
                - configMapRef:
                    name: cm-prediction-water-level
          restartPolicy: OnFailure 
      backoffLimit: 3
      completions: 1
      parallelism: 1
  schedule: 15/15 * * * * # cron 表达式，"从15分开始每隔15分钟执行一次"
  successfulJobsHistoryLimit: 1 # 记录执行成功的记录数量
  failedJobsHistoryLimit: 3 # 记录执行失败的记录数量
```
> 这里介绍下 `restartPolicy`,这个重启策略与 `backoffLimit` 配合使用，
> 当 `restartPolicy` 设置为 `onFailure` 时，容器启动失败了会重启，而不是另起一个新的。
> 当 `restartPolicy` 设置为 `Never` 时，容器启动失败了另新建一个容器。
> `backoffLimit` 是做一个次数限制，当失败次数达到限制时停止重启或新建容器。 

> `schedule` 配置 `cron` 表达式 ， 这里表达式最小单位是分钟


> 启动job

```shell
$ kubectl apply -f myjob.yml 

job.batch/job-prediction-water-level created
```

> 查看 job
```shell
$ kubectl get job -n anxinyun

NAME                                    COMPLETIONS   DURATION   AGE
job-prediction-water-level-1621233900   0/1           110m       110m
job-prediction-water-level-1621239300   1/1           44s        20m
job-prediction-water-level-1621240200   0/1           5m26s      5m26s

```

> 查看 日志
```shell
$ kubectl get pod -n anxinyun

NAME                                          READY   STATUS              RESTARTS   AGE
job-prediction-water-level-1621239300-l2jls   0/1     Completed           0          22m
job-prediction-water-level-1621240200-cvb89   1/1     Running             0          7m44s

$ kubectl logs -n anxinyun job-prediction-water-level-1621240200-cvb89

2021-05-17 16:30:37.270382: W tensorflow/stream_executor/platform/default/dso_loader.cc:55] Could not load dynamic library 'libcuda.so.1'; dlerror: libcuda.so.1: cannot open shared object file: No such file or directory
2021-05-17 16:30:37.270475: I tensorflow/stream_executor/cuda/cuda_diagnostics.cc:156] kernel driver does not appear to be running on this host (job-prediction-water-level-1621240200-cvb89): /proc/driver/nvidia/version does not exist
2021-05-17 16:30:37.270724: I tensorflow/core/platform/cpu_feature_guard.cc:143] Your CPU supports instructions that this TensorFlow binary was not compiled to use: AVX2 FMA
2021-05-17 16:30:37.403503: I tensorflow/core/platform/profile_utils/cpu_utils.cc:102] CPU Frequency: 2300110000 Hz
2021-05-17 16:30:37.407977: I tensorflow/compiler/xla/service/service.cc:168] XLA service 0x7fab4c000b20 initialized for platform Host (this does not guarantee that XLA will be used). Devices:
...
...
...
```

 


