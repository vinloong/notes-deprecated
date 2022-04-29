> k8s 镜像预热有助于提高服务的启动速度

# 开发
## 获取 k8s 服务的镜像

>使用 k8s api 获取指定命名空间的镜像列表

关键代码
```python
def list_deployment(ns):  
    image_list = []  
    deploy_list = apps_v1.list_namespaced_deployment(namespace=ns).items  
    for item in deploy_list:  
        if item.spec.template.spec.containers[0].image.startswith('repository.anxinyun.cn'):  
            project_image = get_project(item.spec.template.spec.containers[0].image)  
            image_tag = get_image_tag(project_image[2])  
            image_list.append({'project': project_image[1], 'name': image_tag[0], 'tag': image_tag[1]})  
    return image_list
```

## 获取 镜像仓库中镜像的最新版本
关键代码：
```python
def get_image_latest_tag(project, image):  
    url = "https://repository.anxinyun.cn/api/repositories/{}/{}/tags?detail=1".format(project, image)  
    r = requests.get(url)  
    if r.status_code == 200:  
        tags = list(map(lambda t: {'created': t['created'], 'tag': t['name']}, r.json()))  
        tags.sort(key=lambda x: x['created'], reverse=True)  
        return tags[0]['tag'] if len(tags) == 1 else tags[0]['tag'] if tags[0]['tag'] != 'latest' else tags[1]['tag']
```

## 拉取镜像
关键代码：
```python
def pull_images():  
    for ns in ns_list:  
        image_list = list_deployment(ns)  
        for image in image_list:  
            if not exist_images(image):  
                image_url = "repository.anxinyun.cn/{}/{}".format(image['project'], image['name'])  
                logger.info("下载镜像 {}:{}  ... ...".format(image_url, image['tag']))  
                client.images.pull(image_url, image['tag'])  
                logger.info("镜像 {}:{} 下载完成。".format(image_url, image['tag']))
```

# 部署
## 制作镜像
```Dockerfile
FROM docker:20-dind-rootless  
  
USER root  
  
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \  
    && apk add --no-cache python3 py3-pip shadow su-exec \  
    && ln -sf python3 /usr/bin/python \  
    && python3 -m ensurepip \  
    && pip3 install --no-cache --upgrade pip setuptools -i https://pypi.tuna.tsinghua.edu.cn/simple \  
    && pip install --no-cache kubernetes requests docker -i https://pypi.tuna.tsinghua.edu.cn/simple \  
    && usermod -aG ping rootless \  
    && echo $'#!/bin/sh \n\  
python /app/syncimages.py' >> /etc/periodic/daily/sync-images \  
    && chmod +x /etc/periodic/daily/sync-images \  
    && apk add tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \  
    && echo "Asia/Shanghai" > /etc/timezone \  
    && apk del tzdata shadow \  
    && rm -rf /var/cache/apk/*  
  
WORKDIR /app  
  
COPY . .  
  
RUN chown -R rootless /app  
  
ENTRYPOINT ["./entrypoint.sh"]
```

## k8s 部署文件
```yaml
kind: DaemonSet  
apiVersion: apps/v1  
metadata:  
  name: syncimages  
  namespace: ops  
  labels:  
    app: tool  
    component: syncimages  
spec:  
  selector:  
    matchLabels:  
      app: tool  
      component: syncimages  
  template:  
    metadata:  
      labels:  
        app: tool  
        component: syncimages  
    spec:  
      containers:  
        - name: syncimages  
          image: 'repository.anxinyun.cn/devops/syncimages:1.2.1' 
          imagePullPolicy: IfNotPresent  
          securityContext:  
            privileged: true  
          volumeMounts:  
            - name: docker-sock  
              mountPath: /var/run/docker.sock  
  affinity:  
    nodeAffinity:  
      requiredDuringSchedulingIgnoredDuringExecution:  
        nodeSelectorTerms:  
          - matchExpressions:  
              - key: node-role.kubernetes.io/worker  
                operator: In  
                values:  
                  - ''  
                  - worker  
    podAntiAffinity:  
      requiredDuringSchedulingIgnoredDuringExecution:  
        - labelSelector:  
            matchExpressions:  
              - key: app  
                operator: In  
                values:  
                  - tool  
              - key: component  
                operator: In  
                values:  
                  - syncimages  
          namespaces:  
            - ops  
          topologyKey: kubernetes.io/hostname  
      volumes:  
        - name: docker-sock  
          hostPath:  
            path: /var/run/docker.sock
```

