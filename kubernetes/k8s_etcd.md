# Etcd 架构与实现解析

**Etcd** 按照官方介绍

> Etcd is a distributed, consistent **key-value** store for **shared configuration** and **service discovery**

是一个分布式的，一致的 key-value 存储，主要用途是共享配置和服务发现。

Etcd 已经在很多分布式系统中得到广泛的使用

> 本文主要解答以下问题 :

1. Etcd是如何实现一致性的？
2. Etcd的存储是如何实现的？
3. Etcd的watch机制是如何实现的？
4. Etcd的key过期机制是如何实现的？

### 为什么需要 Etcd

所有的分布式系统，都面临的一个问题是多个节点之间的数据共享问题(比如谁是 leader， 有哪些成员，依赖任务之间的顺序协调等)，所以分布式系统要么自己实现一个可靠的共享存储来同步信息（比如 Elasticsearch ），要么依赖一个可靠的共享存储服务，而 Etcd 就是这样一个服务。

### Etcd 提供什么能力

Etcd 主要提供以下能力:

1. 提供存储以及获取数据的接口，它通过协议保证 Etcd 集群中的多个节点数据的强一致性。用于存储元信息以及共享配置。
2. 提供监听机制，客户端可以监听某个key或者某些key的变更（v2和v3的机制不同，参看后面文章）。用于监听和推送变更。
3. 提供key的过期以及续约机制，客户端通过定时刷新来实现续约（v2和v3的实现机制也不一样）。用于集群监控以及服务注册发现。
4. 提供原子的CAS（Compare-and-Swap）和 CAD（Compare-and-Delete）支持（v2通过接口参数实现，v3通过批量事务实现）。用于分布式锁以及leader选举。
