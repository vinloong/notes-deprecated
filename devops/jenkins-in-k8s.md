## 前置条件

- **Docker**

- **Kubernetes**

## 安装



```shell
# 创建一个命名空间
$ kubectl create namespace devops

$ kubectl get namespaces

```

 jenkins-pvc.yaml

 ```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-home-pv
  namespace: devops
  labels:
    app: jenkins
spec:
  capacity:          
    storage: 50Gi
  accessModes:       
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain  
  storageClassName: nfs-storage
  mountOptions:
    - hard
    - nfsvers=4.1    
  nfs:            
    path: /data/devops/jenkins/home
    server: 10.8.30.152
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: jenkins-home-pvc
  namespace: devops
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 50Gi
  selector:
    matchLabels:
      app: jenkins
  storageClassName: nfs-storage
---      
apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-versions-pv
  namespace: devops
  labels:
    app: jenkins
spec:
  capacity:          
    storage: 50Gi
  accessModes:       
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain  
  storageClassName: nfs-storage
  mountOptions:
    - hard
    - nfsvers=4.1    
  nfs:            
    path: /data/devops/jenkins/versions
    server: 10.8.30.152
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: jenkins-versions-pvc
  namespace: devops
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 50Gi
  selector:
    matchLabels:
      app: jenkins
  storageClassName: nfs-storage
 ```



  ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191028741.png)



jenkins-rbac.yaml

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkinsci
  namespace: devops
  labels:
    name: jenkins
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: jenkinsci
  labels:
    name: jenkins
subjects:
  - kind: ServiceAccount
    name: jenkinsci
    namespace: devops
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io

```

jenkins-deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  namespace: devops
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      serviceAccount: jenkinsci
      containers:
      - name: jenkins
        image: repository.anxinyun.cn/devops/ud-jenkins:2.289.3-lts
        ports:
        - containerPort: 8080
          name: dashboard
          protocol: TCP
        - containerPort: 50000
          name: agent
          protocol: TCP
        volumeMounts:
        - name: jenkins-home
          mountPath: /var/jenkins_home
        - name: jenkins-version
          mountPath: /var/versions
      volumes:
      - name: jenkins-home
        persistentVolumeClaim:
          claimName: jenkins-home-pvc
      - name: jenkins-version
        persistentVolumeClaim:
          claimName: jenkins-versions-pvc
```





 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191029810.png)

jenkins-service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: jenkins
  namespace: devops
  labels:
    app: jenkins
spec:
  type: NodePort
  ports:
  - name: dashboard
    port: 9090
    targetPort: 8080
    nodePort: 31909
  - name: agent
    port: 50005
    targetPort: 50000
    nodePort: 32505
  selector:
    app: jenkins
```



 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191029303.png)



 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191030495.png)

 

# 配置 动态 slave

## 安装插件

选择 kubernetes 插件，安装

等待。。。

## 配置

系统管理 -> 系统配置 -> Cloud -> 添加一个云

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191031640.png)





 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191032573.png)



 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191032395.png)



挂载 docker 

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191032758.png)





