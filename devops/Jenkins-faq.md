---
title: Jenkins 遇到的问题和解决方案
date: 2021-06-10
categories: 
    - ops
tags: [jenkins]
---

1. `jenkins` 下载安装插件太慢

```shell
cd $JENKINS_HOME/updates
sed -i "s@https://updates.jenkins.io/download@https://repo.huaweicloud.com/jenkins/@g" default.json
```

