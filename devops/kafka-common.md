---
title: kafka 一般操作
date: 2020-04-30
categories: 
    - devops
tags: [kafka]
---


## 创建 topic

```bash
> bin/kafka-topics.sh --zookeeper node36:2181,node38:2181 --create --topic test_topic --partitions 1  --replication-factor 1
WARNING: Due to limitations in metric names, topics with a period ('.') or underscore ('_') could collide. To avoid issues it is best to use either, but not both.
Created topic "test_topic".

# 新版本的kafka 参数 --zookeeper 被 --bootstrap-server 替换了
> bin/kafka-topics.sh --create --bootstrap-server node35:9092,node36:9092,node37:9092 --replication-factor 1 --partitions 1 --topic test_topic

```
<!--more-->

> partitions 指定topic分区数
>
> replication-factor 指定topic每个分区的副本数
>
> - partitions分区数:
>   - partitions ：分区数，控制topic将分片成多少个。可以显示指定，如果不指定则会使用broker(server.properties)中的num.partitions配置的数量
>   - 虽然增加分区数可以提供kafka集群的吞吐量、但是过多的分区数或者或是单台服务器上的分区数过多，会增加不可用及延迟的风险。因为多的分区数，意味着需要打开更多的文件句柄、增加点到点的延时、增加客户端的内存消耗。
>   - 分区数也限制了consumer的并行度，即限制了并行consumer消息的线程数不能大于分区数
>   - 分区数也限制了producer发送消息是指定的分区。如创建topic时分区设置为1，producer发送消息时通过自定义的分区方法指定分区为2或以上的数都会出错的；这种情况可以通过alter –partitions 来增加分区数。
> - replication-factor副本
>   - replication factor 控制消息保存在几个broker(服务器)上，一般情况下等于broker的个数。
>   - 如果没有在创建时显示指定或通过API向一个不存在的topic生产消息时会使用broker(server.properties)中的default.replication.factor配置的数量

## 查看 topic 列表

```bash
> bin/kafka-topics.sh --zookeeper node36:2181,node38:2181 --list
test_topic

# 新版本的kafka 参数 --zookeeper 被 --bootstrap-server 替换了
> bin/kafka-topics.sh --list --bootstrap-server node35:9092,node36:9092,node37:9092

```

## 查看指定topic信息

```bash
> bin/kafka-topics.sh --zookeeper node36:2181,node38:2181 --describe --topic test_topic
# 
> bin/kafka-topics.sh --describe --bootstrap-server node35:9092,node36:9092,node37:9092 --topic test_topic
```



## 控制台向topic生产数据

```bash
> bin/kafka-console-producer.sh --broker-list node35:9092,node36:9092,node37:9092 --topic test_topic

> bin/kafka-console-producer.sh --bootstrap-server node35:9092,node36:9092,node37:9092 --topic test_topic

```



## 控制台消费topic的数据

```bash
> bin/kafka-console-consumer.sh  --zookeeper node36:2181,node38:2181  --topic test_topic --from-beginning

#

> bin/kafka-console-consumer.sh --bootstrap-server node35:9092,node36:9092,node37:9092 --topic test_topic --from-beginning

```



## 扩展topic分区数

> 查看现在的分区情况

```bash
$ bin/kafka-topics.sh --zookeeper node36:2181,node38:2181 --describe --topic test_topic
Topic:test_topic    PartitionCount:1        ReplicationFactor:1     Configs:
        Topic: test_topic   Partition: 0    Leader: 1002    Replicas: 1002  Isr: 1002
```

> 只有一个分区，下面执行命令增加到5个

```bash
$ bin/kafka-topics.sh --zookeeper node36:2181,node38:2181  --alter --topic test_topic --partitions 5
WARNING: If partitions are increased for a topic that has a key, the partition logic or ordering of the messages will be affected
Adding partitions succeeded!
```

> 再查看 topic 信息

```bash
$ bin/kafka-topics.sh --zookeeper node36:2181,node38:2181 --describe --topic test_topic
Topic:test_topic    PartitionCount:5        ReplicationFactor:1     Configs:
        Topic: test_topic   Partition: 0    Leader: 1002    Replicas: 1002  Isr: 1002
        Topic: test_topic   Partition: 1    Leader: 1003    Replicas: 1003  Isr: 1003
        Topic: test_topic   Partition: 2    Leader: 1001    Replicas: 1001  Isr: 1001
        Topic: test_topic   Partition: 3    Leader: 1002    Replicas: 1002  Isr: 1002
        Topic: test_topic   Partition: 4    Leader: 1003    Replicas: 1003  Isr: 1003
```



## 删除topic

```bash
$ bin/kafka-topics.sh --zookeeper node36:2181,node38:2181 --delete --topic test_topic
Topic test_topic is marked for deletion.
Note: This will have no impact if delete.topic.enable is not set to true.

> bin/kafka-topics.sh --bootstrap-server broker_host:port --delete --topic my_topic_name
```

>  **慎用，只会删除zookeeper中的元数据，消息文件须手动删除**



## 修改副本数量



> 先查看topic 的详细信息

```bash
$ bin/kafka-topics.sh --zookeeper node36:2181,node38:2181 --describe --topic test_topic

Topic:test_topic    PartitionCount:5        ReplicationFactor:1     Configs:
        Topic: test_topic   Partition: 0    Leader: 1002    Replicas: 1002  Isr: 1002
        Topic: test_topic   Partition: 1    Leader: 1003    Replicas: 1003  Isr: 1003
        Topic: test_topic   Partition: 2    Leader: 1001    Replicas: 1001  Isr: 1001
        Topic: test_topic   Partition: 3    Leader: 1002    Replicas: 1002  Isr: 1002
        Topic: test_topic   Partition: 4    Leader: 1003    Replicas: 1003  Isr: 1003
```

> 根据 topic 的分区情况自己修改 partitions-topic.json 文件进行配置
>
> 现在可以看到  test_topic  partitions 数量只有 1个，现在我们增加到 2个:

```json
{
    "version": 1,
    "partitions": [
        {
            "topic": "test_topic",
            "partition": 0,
            "replicas": [1002,1003]
        },
        {
            "topic": "test_topic",
            "partition": 1,
            "replicas": [1003,1001]
        },
        {
            "topic": "test_topic",
            "partition": 2,
            "replicas": [1001,1002]
        },
        {
            "topic": "test_topic",
            "partition": 3,
            "replicas": [1002,1003]
        },
        {
            "topic": "test_topic",
            "partition": 4,
            "replicas": [1003,1001]
        }

    ]
}

```

> 执行副本搬迁

```bash
$ bin/kafka-reassign-partitions.sh --zookeeper  node36:2181,node38:2181 --reassignment-json-file replications-topic.json --execute

Current partition replica assignment

{"version":1,"partitions":[{"topic":"test_topic","partition":0,"replicas":[1002]},{"topic":"test_topic","partition":3,"replicas":[1002]},{"topic":"test_topic","partition":2,"replicas":[1001]},{"topic":"test_topic","partition":1,"replicas":[1003]},{"topic":"test_topic","partition":4,"replicas":[1003]}]}

Save this to use as the --reassignment-json-file option during rollback
Successfully started reassignment of partitions.
```



> 查看搬迁情况

```bash
$ bin/kafka-reassign-partitions.sh --zookeeper node36:2181,node38:2181 --reassignment-json-file partitions-topic.json --verify

Status of partition reassignment: 
Reassignment of partition [test_topic,0] completed successfully
Reassignment of partition [test_topic,3] completed successfully
Reassignment of partition [test_topic,1] completed successfully
Reassignment of partition [test_topic,2] completed successfully
Reassignment of partition [test_topic,4] completed successfully

```

> 现在查看topic 信息

```bash
$ bin/kafka-topics.sh --zookeeper node36:2181,node38:2181 --describe --topic test_topic

Topic:anxinyun_alarm    PartitionCount:5        ReplicationFactor:2     Configs:
        Topic: test_topic   Partition: 0    Leader: 1002    Replicas: 1002,1003     Isr: 1002,1003
        Topic: test_topic   Partition: 1    Leader: 1003    Replicas: 1003,1001     Isr: 1003,1001
        Topic: test_topic   Partition: 2    Leader: 1001    Replicas: 1001,1002     Isr: 1001,1002
        Topic: test_topic   Partition: 3    Leader: 1002    Replicas: 1002,1003     Isr: 1002,1003
        Topic: test_topic   Partition: 4    Leader: 1003    Replicas: 1003,1001     Isr: 1003,1001

```

