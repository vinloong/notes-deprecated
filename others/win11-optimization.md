# win 11 速度优化



## 关闭磁盘优化



## 关闭 search

打开服务：

禁用 `Windows Search`

## 关闭自动更新

禁用 `Windows Update`

任务计划程序 –> windows –> `Windows Update` 

结束 并 禁用 `Scheduled Start`



## 关闭诊断跟踪

服务：

禁用 `Diagnostic Policy Service`

禁用 `Diagnostic Service Host`

禁用 `Diagnostic System Host`



## 关闭杀软

运行`gpedit.msc`  ，打开组策略编辑器

计算机配置 –> 管理模板 –> windows 组件 –> Microsoft Defender 防病毒

右边

启用 `关闭 Microsoft Defender 防病毒`



实时保护中：

启用`关闭实时保护`

禁用 `打开行为监视`



## 开启time

服务



启用 `Windows Time` : 延时启动



## 修改锁屏壁纸



个性化 修改 `个性化锁屏界面` 换掉 `Windows 聚焦`





## 修改引导时间

msconfig

`引导` –> 超时 改小点 默认 30s 



## 其他



### 高级系统设置

 设置 –>  视觉效果 

选则 `调整为最佳性能`

 下面选择 `平滑屏幕字体边缘` 和 `显示缩略图而不是显示图标`



### 禁用启动 



### 高性能

管理员运行
```cmd
powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
```
