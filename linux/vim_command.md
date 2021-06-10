---
title: VIM 编辑器
date: 2020-10-18
categories: 
    - linux
tags: [linux]
---


## VIM 文本编辑器
> 一般 `linux` 系统上默认都会安装 `vim` 文本编辑器。



## 快捷操作

### 批量添加注释

> 有两种方法：

#### 使用可视模式

##### 注释

1. 按 **`Ctrl+ v`** 进入块选择模式,

 ![](http://imgchr.lingwenlong.com/notes/img/20210126170235.png)


2. 然后移动光标选中你要注释的行,

 ![](http://imgchr.lingwenlong.com/notes/img/20210126170347.png)


3. 再按大写的 **`I`** 进入首行插入模式，输入注释符号比如 `#`,

 ![](http://imgchr.lingwenlong.com/notes/img/20210126172147.png)


4. 输入完成后，按 **两下** `ESC`, vim 会自动将你选中的行都加上注释，保存退出

 ![](http://imgchr.lingwenlong.com/notes/img/20210126172252.png)


##### 取消注释

1. **`Ctrl + v`** 进入块选择模式，

 ![](http://imgchr.lingwenlong.com/notes/img/20210126172651.png)

2. 选中你要删除的行首的注释符号，

 ![](http://imgchr.lingwenlong.com/notes/img/20210126172746.png)

3. 选好之后按 **d** 即可删除注释，**ESC** 保存退出。

 ![](http://imgchr.lingwenlong.com/notes/img/20210126172807.png)



#### 使用替换命令

##### 注释

使用下面命令在指定的行首添加注释。

使用名命令格式： **`:起始行号,结束行号s/^/注释符/g`**

 ![](http://imgchr.lingwenlong.com/notes/img/20210126174834.png)



 ![](http://imgchr.lingwenlong.com/notes/img/20210126174928.png)

##### 取消注释

使用名命令格式： **`:起始行号,结束行号s/^注释符//g`**

 ![](http://imgchr.lingwenlong.com/notes/img/20210126175058.png)

 ![](http://imgchr.lingwenlong.com/notes/img/20210126175116.png)

 
