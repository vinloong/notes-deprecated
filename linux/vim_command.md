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

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191058873.png)


2. 然后移动光标选中你要注释的行,

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191059608.png)


3. 再按大写的 **`I`** 进入首行插入模式，输入注释符号比如 `#`,

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191059940.png)


4. 输入完成后，按 **两下** `ESC`, vim 会自动将你选中的行都加上注释，保存退出

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191059429.png)


##### 取消注释

1. **`Ctrl + v`** 进入块选择模式，

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191100130.png)

2. 选中你要删除的行首的注释符号，

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191100634.png)

3. 选好之后按 **d** 即可删除注释，**ESC** 保存退出。

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191100231.png)



#### 使用替换命令

##### 注释

使用下面命令在指定的行首添加注释。

使用名命令格式： **`:起始行号,结束行号s/^/注释符/g`**

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191101730.png)



 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191101021.png)

##### 取消注释

使用名命令格式： **`:起始行号,结束行号s/^注释符//g`**

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191101890.png)

 ![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202201191101210.png)

 
