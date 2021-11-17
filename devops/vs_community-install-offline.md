[TOC]



# Visual Studio 离线安装



## 下载 [Visual Studio 引导程序](https://aka.ms/vs/17/release/vs_community.exe)

## 创建本地安装缓存



- 完整功能(耗时将很长)：

  ```powershell
  vs_community.exe  --layout e:\downloads\vslayout --lang zh-CN
  ```

  

- 对于 .NET Web 和.NET 桌面开发，请运行：

  ```powershell
  vs_community.exe --layout e:\downloads\vslayout --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NetWeb --add Component.GitHub.VisualStudio --includeOptional --lang zh-CN
  ```

  

- 对于 .NET 桌面和 Office 开发，请运行：

  ```powershell
  vs_community.exe --layout e:\downloads\vslayout --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.Office --includeOptional --lang zh-CN
  ```

  

- 对于 C++ 桌面开发，请运行:

  ```powershell
  vs_community.exe --layout e:\downloads\vslayout --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended --lang zh-CN
  ```

  

## 从本地缓存安装 Visual Studio



```powershell
# 使用 "完整功能" 下载本地缓存的
e:\downloads\vslayout\vs_community.exe --noweb

# 使用 ".NET Web 和.NET 桌面开发" 下载本地缓存的
e:\downloads\vslayout\vs_community.exe --noweb --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NetWeb --add Component.GitHub.VisualStudio --includeOptional

# 使用 ".NET 桌面和 Office 开发" 下载本地缓存的
e:\downloads\vslayout\vs_community.exe --noweb --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.Office --includeOptional

# 使用 "C++ 桌面开发" 下载本地缓存的
e:\downloads\vslayout\vs_community.exe --noweb --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended 

```



## 参考

> [创建脱机安装](https://docs.microsoft.com/zh-cn/visualstudio/install/create-an-offline-installation-of-visual-studio?view=vs-2022)