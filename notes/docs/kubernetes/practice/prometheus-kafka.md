---
title: 使用 Prometheus 监控 kafka
date: 2020-09-26
categories: 
    - devops
tags: [prometheus,kafka]
---

## 监控配置
### 1.  启动 JMX 服务

> 首先需要在 Kafka 中启用 JMX 服务以获取资源信息

```bash
# 1. 修改 kafka-server-start.sh 脚本
# 在第一行增加 export JMX_PORT="9999"
# ambari kafka 路径： `/usr/hdp/current/kafka-broker`
cd /usr/hdp/current/kafka-broker
vi bin/kafka-server-start.sh
# 增加
export JMX_PORT="9999"
```

<!--more-->

> 修改完所有节点后，在ambari 重启所有 kafka节点

### 2. 启动 jmx_exporter

> 需要启动 jmx_exporter，让 JMX 信息可以直接通过 HTTP 方式访问，以便 ARMS Prometheus 监控抓取

> 我已经做好docker 镜像，上传到镜像仓库了,修改一下yaml文件使用docker-compose 起一下就可以

```yaml
# docker-compose.yml
version: '2.0'
services:
  kafka-expoter:
    # 打包好的镜像
    image: repository.anxinyun.cn/devops/jmx_prometheus_httpserver:0.13.1 
    container_name: jmx_prometheus_httpserver
    restart: always
    # 修改下 ip 
    command: ["bash","./start.sh","10.8.30.37"]
    ports:
      - 9997:9997
      - 9998:9998
```

```bash
# 启动服务
docker-compose -f ./docker-compose.yml up -d
```



### 3. 配置 RMS Prometheus 监控以抓取 Kafka 应用的数据

在 配置文件增加 

```yaml
additionalScrapeConfigs: []
# 以下是增加的内容
- job_name: 'kafka-cluster'
  static_configs:
   - targets:
     - '10.8.30.35:9997'
     - '10.8.30.36:9997'
     - '10.8.30.37:9997'
```

>  重启  Prometheus

### 4. 通过 Grafana 大盘展示 Kafka 应用的数据

> 1. 打开 Prometheus 的 Grafana 首页，鼠标悬浮在左边 菜单栏 ‘+’  ，在子菜单中选择 ‘Import’
>
> 2. 在打开的界面中 Grafana.com Dashboard 输入框中输入 `10973`  ，然后单击 Load , 
>
> 3. 在配置选项中
>
>     Name 配置 dashboard 名称
>
>    Fold 配置你想在哪个文件夹显示这个dashboard
>
> 4. 单击 Import (Overwrite)



## 监控报警配置

### kafka 重要的监控指标有几个

#### kafka broker 层面

| metric name                      | description                                                  |
| --------------------- | -------------------------------------------------|
| OfflinePartitionsCount| 下线的 partition 的数量, 一般 >0 就说明集群有问题   |
| ActiveControllerCount | 标记哪个 broker 节点是 controller         |
| UncleanLeaderElectionPerSec| 争议的 leader 选举次数                |
| PartitionCount | 每个 broker 节点的 topic partition 的数量, 用于决定是否需要rebalance |
| UnderReplicatedPartitions | 复制中的 Partition 数量 |
| Bytes In bytes Per Topic Top 10 | 按照数据量计算前十个写入的 Topic |
| Bytes Out bytes Per Topic Top 10 | 按照数据量计算前十个读取的 Topic |
| Message In Per Topic Top 10      | 按照消息量计算前十个读取的 Topic |

#### JVM 层面

这个重点关注两个指标

| metric name                      | description                                                  |
| --------------------- | -------------------------------------------------|
| JVM Memory Usage | JVM Heap 占用的内存                       |
| Time Spend in GC | JVM GC 所占的时间比例, 定位是否有 GC 问题 |

#### 系统层面

常见的指标

| metric name    | description                     |
| -------------- | ------------------------------- |
| CPU Usage      | 系统 CPU 使用率                 |
| Memory Usage   | 系统 Memory 使用率              |
| Disk Usage     | 磁盘占用                        |
| IO Utilization | IO 使用率, 看是否有磁盘 IO 瓶颈 |
| Network In/Out | 网络吞吐                        |



我们配置  OfflinePartitionsCount 的告警，主要是发现kafka集群的问题

其他的指标一般不会有问题，可以重点关注


### OfflinePartitionsCount的告警配置

首先 添加一个 panel  ：



Query 

> A  指标 填写 `max(kafka_controller_kafkacontroller_offlinepartitionscount)`

![](https://resources.lingwenlong.com/share/img-prometheus-kafka-01.png)

![](https://resources.lingwenlong.com/share/img-prometheus-kafka-02.png)

![](https://resources.lingwenlong.com/share/img-prometheus-kafka-03.png)

最后展示效果如下：

![](https://resources.lingwenlong.com/share/img-prometheus-kafka-04.png)

告警通知：

![](https://resources.lingwenlong.com/share/img-prometheus-kafka-05.png)
