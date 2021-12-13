---
title: linux 命令 ————  tar
date: 2020-05-26
categories: 
    - linux
tags: [linux]
---

> 对文件进行打包，默认情况并不会压缩，如果指定了相应的参数，
> 它还会调用相应的压缩程序（如gzip和bzip等）进行压缩和解压


## 部分参数说明

> `-c` : 新建打包文件 (create)
> `-t` : 查看打包文件的内容含有哪些文件名
> `-x` : 解打包或解压缩的功能，可以搭配-C（大写）指定解压的目录，注意-c,-t,-x不能同时出现在同一条命令中
> `-j` : 通过bzip2的支持进行压缩/解压缩, 一般添加`.bz2`后缀
> `-z` : 通过gzip的支持进行压缩/解压缩， 默认压缩倍数 6倍  （0-9），一般添加`.gz`后缀
> `-v` : 在压缩/解压缩过程中，将正在处理的文件名显示出来
> `-f filename` : filename为要处理的文件, `f` 后面需要紧跟文件名
> `-C dir` : 指定压缩/解压缩的目录dir
> `-p` : 使用文件原来的属性
> `-P` : 使用绝对路径压缩
> `-N` : 比后面跟的日期新的文件才会被打包
> `--exclude` : 排除文件


```bash
# 压缩：
$ tar -jcv -f filename.tar.bz2 ${dir or file} 

# 查询：
$ tar -jtv -f filename.tar.bz2 

# 解压：
tar -jxv -f filename.tar.bz2 -C ${dir}

# 压缩文件
> tar -czf test.tar.gz /test1 /test2

# 列出压缩文件列表
> tar -tzf test.tar.gz

# 解压文件
> tar -xvzf test.tar.gz

```


