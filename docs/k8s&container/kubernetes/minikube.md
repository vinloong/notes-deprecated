



`minikube` 本地设置一个k8s 集群，让 k8s 的学习和开发更简单。

你只需要一个 Docker 容器(或其他兼容的) 或 一个虚拟机环境，启动 k8s 只需要一个简单的命令 `minikube start`.



推荐配置：

- 至少 **2核2G** 
- 至少 **20G** 硬盘
- 可以联网
- 容器或虚拟机(Docker、Hyper-V、Podman、VirtualBox、VMware等)



# 安装



<details><summary>Linux</summary>
<p>
   
	
## Linux

```bash

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

sudo install minikube-linux-amd64 /usr/local/bin/minikube

```

</p>
</details>


<details><summary>Mac OS</summary>
<p>

## Mac OS

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64

sudo install minikube-darwin-amd64 /usr/local/bin/minikube
```

</p>
</details>




<details><summary>Windows</summary>
<p>


	
## Windows

1. 下载并安装[最新版本](https://storage.googleapis.com/minikube/releases/latest/minikube-installer.exe)

2. 添加`minikube.exe`到环境变量
   
   使用管理员身份打开`PowerShell`执行
   
   
   ```powershell
   $oldPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)
   if ($oldPath.Split(';') -inotcontains 'C:\minikube'){ `
     [Environment]::SetEnvironmentVariable('Path', $('{0};C:\minikube' -f $oldPath), [EnvironmentVariableTarget]::Machine) `
   }
   ```


过程中会让你选择驱动：

官方推荐 `Hyper-V - VM` 和 `Docker - VM + Container`

本人使用的 `Hyper-V - VM`

```powershell
# 设置 Hyper-V 为默认驱动
minikube config set driver hyperv
```
</p>
</details>



# 启动集群



```powershell


minikube start 

```



