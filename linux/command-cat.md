---
title: Linux 常用命令之 cat
date: 2022-01-19
categories: 
    - linux
tags: [linux]
---

[TOC]
# Linux 常用命令之 cat
`cat` 是 linux 中使用频率较高的命令之一。
这个命令有三个主要功能：
- 创建文件
- 读取和显示文件内容
- 更新修改文件内容

下面我们来一次介绍它的这些用法

## 创建文件
我们来创建一个名为 `foo.txt` 的文件。
```shell
$ cat > foo.txt
foo
hello
!
```
按 `Ctrl+D/C` 返回命令行，
```shell
$ ls
foo.txt
```
我们看到已经创建了 `foo.txt` 文件。
下面我们再用同样的命令创建一个 `spam.txt`文件：
```shell
$ cat > spam.txt 
spam
eggs
haha
.
```
查看：
```shell
$ ls
foo.txt  spam.txt
```

如果我们向已存在的文件追加内容，使用 `>>`
```shell
$ cat >> foo.txt
这是追加内容。
```

```ad-warning
   如果已经存在名为 foo.txt 的文件，在使用 > 运算符的 `cat` 命令将覆盖该文件。

```
   
## 读取文件内容
现在来看看我们创建的文件里有什么：
```shell
$ cat foo.txt 
foo
hello
!
这是追加内容。
$ cat spam.txt 
spam
eggs
haha
.
```

命令中加上 `-n` 参数，可以看到文件里有多少行。
```shell
$ cat -n spam.txt
     1	spam
     2	eggs
     3	haha
     4	.
```

## 拼接文件
```shell
$ cat foo.txt spam.txt 
foo
hello
!
这是追加内容。
spam
eggs
haha
.
```

上面的命令紧紧是显示。下面我们把拼接后的内容输出到新的文件中：
```shell
$ cat foo.txt spam.txt > fooSpam.txt
$ cat fooSpam.txt 
foo
hello
!
这是追加内容。
spam
eggs
haha
.
```

## 倒序显示内容
```shell
$ tac foo.txt 
这是追加内容。
!
hello
foo
```

## 追加一个文件内容到另一个文件中
```shell
$ cat num.txt >> test1.txt
$ cat test1.txt 
xxx
123456789
```

## 追加内容到文件中
```shell
$ cat << EOF > test.txt
> This is a test file.
> Hello, my name is Hanmeimei.
> EOF
$ cat test.txt 
This is a test file.
Hello, my name is Hanmeimei.
```

