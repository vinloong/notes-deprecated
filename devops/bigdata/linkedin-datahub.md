 ![image-20220311161712496](https://cdn.jsdelivr.net/gh/vinloong/imgchr/notes/img/202203111617619.png)

# 分析脚本

执行的是 `./quickstart.sh`

里面涉及的yaml 文件有：

`quickstart/docker-compose.monitoring.quickstart.yml`

`docker-compose.consumers.yml`

`docker-compose.yml`

`quickstart/docker-compose-without-neo4j.quickstart.yml`



# 查看镜像配置文件

## schema-registry

依赖 zookeepker 和kafka

zookeeper 配置在 `/etc/schema-registry/schema-registry.properties`

```properties
port=8081
kafkastore.connection.url=zookeeper:2181
kafkastore.topic=_schemas
debug=false
```

 `/etc/schema-registry/admin.properties`

```
connection.url=zookeeper:2181
```

没有找到kfka配置?

`/etc/schema-registry/connect-avro-distributed.properties`

`/etc/schema-registry/connect-avro-standalone.properties`



## kafka-setup

依赖 kafka 、schema-registry
在 `./kafka-setup/env/docker.env`:

```
KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181
KAFKA_BOOTSTRAP_SERVER=broker:29092
```



##  elasticsearch-setup

依赖 es

`./elasticsearch-setup/env/docker.env`

```
ELASTICSEARCH_HOST=elasticsearch
ELASTICSEARCH_PORT=9200
ELASTICSEARCH_PROTOCOL=http
```



## datahub-gms

依赖项：

- elasticsearch-setup


- kafka-setup
- mysql
- neo4j

配置在  `./datahub-gms/env/docker*.env`

## datahub-frontend-react

没有直接说明依赖，查看配置文件发现，对 kafka 、es 有依赖

`./datahub-frontend/env/docker.env`



## datahub-actions

同上，没有明确说明，但是对 kafka 、schema registry 有依赖
`./datahub-actions/env/docker.env`

## mysql-setup



