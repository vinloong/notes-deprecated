# edge cloud

# edge core

```shell
# 下载 kubeedge
$ wget https://github.com/kubeedge/kubeedge/releases/download/v1.7.1/kubeedge-v1.7.1-linux-arm.tar.gz

# 解压
$ tar zxvf kubeedge-v1.7.1-linux-arm.tar.gz

$ mv kubeedge-v1.7.1-linux-arm/edge/edgecore /usr/local/bin

$ mkdir -p /etc/kubeedge/config

$ edgecore --defaultconfig > /etc/kubeedge/config/edgecore.yaml
```

```yaml
# With --defaultconfig flag, users can easily get a default full config file as reference, with all fields (and field descriptions) included and default values set. 
# Users can modify/create their own configs accordingly as reference. 
# Because it is a full configuration, it is more suitable for advanced users.

apiVersion: edgecore.config.kubeedge.io/v1alpha1
database:
  aliasName: default
  dataSource: /var/lib/kubeedge/edgecore.db
  driverName: sqlite3
kind: EdgeCore
modules:
  dbTest:
    enable: false
  deviceTwin:
    enable: true
  edgeHub:
    enable: true
    heartbeat: 15
    httpServer: https://10.8.30.38:10002
    projectID: e632aba927ea4ac2b575ec1603d56f10
    quic:
      enable: false
      handshakeTimeout: 30
      readDeadline: 15
      server: 10.8.30.38:10001
      writeDeadline: 15
    rotateCertificates: true
    tlsCaFile: /etc/kubeedge/ca/rootCA.crt
    tlsCertFile: /etc/kubeedge/certs/server.crt
    tlsPrivateKeyFile: /etc/kubeedge/certs/server.key
    token: 5e630e7bf11b00a77a513233e067788e12d36179be1d4b83d804bf77c463781e.eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2MjY3Mjk1MTd9.s3XbFEZ1O2XvsVzRnTFpHPGNbOzttjvh5cp3xzxCeCY
    websocket:
      enable: true
      handshakeTimeout: 30
      readDeadline: 15
      server: 10.8.30.38:10000
      writeDeadline: 15
  edgeMesh:
    enable: false
    lbStrategy: RoundRobin
    listenInterface: docker0
    listenPort: 40001
    subNet: 9.251.0.0/16
  edgeStream:
    enable: false
    handshakeTimeout: 30
    readDeadline: 15
    server: 127.0.0.1:10004
    tlsTunnelCAFile: /etc/kubeedge/ca/rootCA.crt
    tlsTunnelCertFile: /etc/kubeedge/certs/server.crt
    tlsTunnelPrivateKeyFile: /etc/kubeedge/certs/server.key
    writeDeadline: 15
  edged:
    cgroupDriver: systemd
    cgroupRoot: ""
    cgroupsPerQOS: true
    clusterDNS: ""
    clusterDomain: ""
    cniBinDir: /opt/cni/bin
    cniCacheDirs: /var/lib/cni/cache
    cniConfDir: /etc/cni/net.d
    networkPluginName: cni
    concurrentConsumers: 5
    devicePluginEnabled: false
    dockerAddress: unix:///var/run/docker.sock
    edgedMemoryCapacity: 7852396000
    enable: true
    enableMetrics: false
    gpuPluginEnabled: false
    hostnameOverride: raspberrypi-1
    imageGCHighThreshold: 80
    imageGCLowThreshold: 40
    imagePullProgressDeadline: 60
    maximumDeadContainersPerPod: 1
    networkPluginMTU: 1500
    nodeIP: 10.8.30.100
    nodeStatusUpdateFrequency: 10
    podSandboxImage: kubeedge/pause-arm:3.1
    registerNode: true
    registerNodeNamespace: default
    remoteImageEndpoint: unix:///run/containerd/containerd.sock
    remoteRuntimeEndpoint: unix:///run/containerd/containerd.sock
    runtimeRequestTimeout: 2
    runtimeType: remote
    volumeStatsAggPeriod: 60000000000
  eventBus:
    enable: true
    eventBusTLS:
      enable: false
      tlsMqttCAFile: /etc/kubeedge/ca/rootCA.crt
      tlsMqttCertFile: /etc/kubeedge/certs/server.crt
      tlsMqttPrivateKeyFile: /etc/kubeedge/certs/server.key
    mqttMode: 2
    mqttQOS: 0
    mqttRetain: false
    mqttServerExternal: tcp://127.0.0.1:1883
    mqttServerInternal: tcp://127.0.0.1:1884
    mqttSessionQueueSize: 100
  metaManager:
    contextSendGroup: hub
    contextSendModule: websocket
    enable: true
    metaServer:
      debug: false
      enable: false
    podStatusSyncInterval: 90
    remoteQueryTimeout: 90
  serviceBus:
    enable: false
```

主要 修改容器运行时、cgroup 驱动

运行 

```shell
edgecore
```

如下错误：

> edgecore[45472]: E0407 06:52:35.569727   45472 edged.go:742] Failed to start container manager, err: system validation failed - Following Cgroup subsystem not mounted: [memory]
> edgecore[45472]: E0407 06:52:35.569777   45472 edged.go:293] initialize module error: system validation failed - Following Cgroup subsystem not mounted: [memory]

```shell
# 内存资源的cgroups机制没有开启

# 修改启动参数
$ vim /boot/cmdline.txt

# 追加
cgroup_memory=1 cgroup_enable=memory


# 查看可用的cgroup
$ cat /proc/cgroups
```

```bash
scp k8s-master:/etc/cni/net.d/* /etc/cni/net.d/
```
