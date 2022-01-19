# 利用Ambari 安装

kafka 目录 ： `/usr/hdp/current/kafka-broker`

# 手动安装

###  zookeeper

> kafka 依赖zookeeper 管理自身集群(Broker, Offset, Producer, Consumer等),所以要先安装zookeeper.

 - 下载 
   
   ```
   wget http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz

   ```
 - 解压
    ```
        tar -zxvf zookeeper-3.4.10.tar.gz
    ```
 - 配置
   ``` bash
       cd zookeeper-3.4.10/conf
       cp zoo_sample.cfg zoo.cfg
       # 修改 dataDir(数据保存路径): 路径后面不能有注释
       dataDir=/home/test/zookeeper-3.4.10/data
       # 增加集群配置节点 hostname:port1:port2  port1 是node间的通信端口，
       # port2是选举端口
       server.0=test-n4:4001:4002
       server.1=test-n5:4001:4002
       server.2=test-n6:4001:4002
   ```
   > zookeeper 默认服务端口是：2181

   > 在上述配置的dataDir路径下创建一个 myid 文件

   ``` bash
    # 每个节点都增加 myid 内容是节点编号
    echo '0' >> myid
    # echo '1' >> myid
    # echo '2' >> myid
   ```
 - 运行
   ``` bash
   bin/zkServer.sh start
   # 查看状态
   bin/zkServer.sh status
   ```
   ```
    test@test-n3:~/services/zookeeper$ bin/zkServer.sh status
    ZooKeeper JMX enabled by default
    Using config: /home/test/services/zookeeper/bin/../conf/zoo.cfg
    Mode: leader

    test@test-n1:~/services/zookeeper$ bin/zkServer.sh status
    ZooKeeper JMX enabled by default
    Using config: /home/test/services/zookeeper/bin/../conf/zoo.cfg
    Mode: follower

    test@test-n3:~/services/zookeeper$ bin/zkServer.sh status
    ZooKeeper JMX enabled by default
    Using config: /home/test/services/zookeeper/bin/../conf/zoo.cfg
    Mode: leader

   ```
   > test-n3 是leader
   
 - 停止
    ```
    bin/zkServer.sh stop
    ```


### kafka

 - 下载并解压
    ```
    wget http://mirror.bit.edu.cn/apache/kafka/0.11.0.1/kafka_2.12-0.11.0.1.tgz
    tar -zxvf kafka_2.12-0.11.0.1.tgz
    ```
 - 配置
    ``` bash
    cd kafka_2.12-0.11.0.1
    vi config/server.properties
    # 修改
    broker.id=0 # 每个节点不能相同 1, 2
    delete.topic.enable=true
    listeners=PLAINTEXT://test-n1:9092
    log.dirs=/home/anxin/kafka_2.12-0.11.0.1/kafka-logs
    zookeeper.connect=test-n1:2181,test-n2:2181,test-n3:2181
    ```
 - 启动

    ```
    bin/kafka-server-start.sh -daemon config/server.properties

    ```
 - 查看topic状态
    ```
    bin/kafka-topics.sh --describe --zookeeper test-n1:2181,test-n2:2181,test-n3:2181 
--topic data

    ```
 - 常用命令
    ``` bash
    # 创建一个名为data的topic, 拥有1个分区，1个副本
    ./kafka-topics.sh --create --zookeeper test-n1:2181,test-n2:2181,test-n3:2181 --replication-factor 1 --partitions 1 --topic topic_test

    # 查看所有topics
./kafka-topics.sh --list --zookeeper test-n1:2181
    
# 查看topic的状态
    ./kafka-topics.sh --zookeeper test-n1:2181,test-n2:2181,test-n3:2181 --describe  --topic topic_test
    
# 控制台生产数据 broker ambari 安装的使用6667端口 ，自己手动安装的使用 9092 端口
    ./kafka-console-producer.sh --broker-list test-n1:6667 --topic topic_test
    
# 控制台消费
    ./kafka-console-consumer.sh --bootstrap-server test-n1:6667 --topic topic_test --from-beginning
    
    # 查看topic某分区偏移量最大（小）值: time为-1时表示最大值,time为-2时表示最小值
    ./kafka-run-class.sh kafka.tools.GetOffsetShell --topic test_data --time -1 --broker-list test-n1:6667 --partitions 0
    # 查看topic 偏移量最大（小）值: time为-1时表示最大值,time为-2时表示最小值
    ./kafka-run-class.sh kafka.tools.GetOffsetShell --topic test_data --time -1 --broker-list test-n1:6667
    
    # 修改 topic test_data 分区 10 (只能增加不能减少)
    ./kafka-topics.sh --zookeeper test-n1:2181 --alter --topic test_data --partitions 10
    
    # 查看 consumer group 列表
    ./kafka-consumer-groups.sh --new-consumer --bootstrap-server test-n1:6667 --list
    # ./kafka-consumer-groups.sh --zookeeper test-n1:2181 --list
    
    # 查看特定consumer group 详情
    ./kafka-consumer-groups.sh --new-consumer --bootstrap-server test-n1:6667 --group test --describe
    # /kafka-consumer-groups.sh --zookeeper test-n1:2181 --group console-consumer-11967 --describe
    
    ```

- 删除 topic

  ```bash
  # 删除topic
  ./kafka-topics.sh --delete --zookeeper test-n1:2181 --topic topic_test
  ./kafka-run-class.sh kafka.admin.DeleteTopicCommand --zookeeper test-n1:2181 --topic topic_test
  
  # 如果 `delete.topic.enable=true` 则直接删除，否则topic仅仅被标记为删除
  
  # 从zk中删除topic ; 删除完成后重启zookeeper和kafka服务；
  ./zkCli.sh
  ls /brokers/topics
  rm /brokers/topics/topic_test
  
  ```

  