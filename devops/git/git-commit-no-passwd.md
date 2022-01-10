---
title: git 提交免密
date: 2020-03-28
categories: 
    - devops
tags: [git]
---


## 生成ssh key，并添加到ssh-agent

```bash
$ ssh-keygen -t rsa -b 4096 -C "your_email@example.com" 修改成你自己的邮箱地址
```

<!--more-->

![](https://raw.githubusercontent.com/literaryloong/imgchr/master/img/20200928164130.png)

> 验证ssh-agent 是否已在后台运行

```bash
$ eval $(ssh-agent -s)
```

![](https://raw.githubusercontent.com/literaryloong/imgchr/master/img/20200928164357.png)

## 添加key到ssh-agent

```bash
$ ssh-add ~/.ssh/id_rsa
```

## 添加public key到 github

![](https://raw.githubusercontent.com/literaryloong/imgchr/master/img/20200928164636.png)

> tile 随便填, key 把上面生成的 `id_rsa.pub` 复制过来


## 使用 TortoiseGit 免密

> 打开 TortoiseGit 自带的 `PuTTYgen`
![](https://raw.githubusercontent.com/literaryloong/imgchr/master/img/20200928164923.png)


![](https://raw.githubusercontent.com/literaryloong/imgchr/master/img/20200928165104.png)

> `Load` 上面创建的 `id_rsa`,生成 `id_rsa.ppk`文件

push 时选中 自动加载 Putty 密钥

![](https://raw.githubusercontent.com/literaryloong/imgchr/master/img/20200928165415.png)

