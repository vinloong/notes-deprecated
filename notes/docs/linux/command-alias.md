---
title: linux 命令之 alias
date: 2020-10-18
categories: 
    - linux
tags: [linux]
---

## 设置指令的别名

```bash
alias name='command line'
```

<!--more-->

> 参数：
> -p：    打印出现有的别名（唯一的参数）
> 若不加任何参数，则列出目前所有的别名设置

```bash
# cp来代替cp -i，而且cp -i这条命令依旧有效
alias cp='cp -i'

```

## 查看alias

> 列出目前所有的别名设置

```bash
alias    
# 或 
alias -p
```

> 查看具体一条指令的别名

```bash
alias cp
```

## 删除别名

```bash
unalias $name
```

## 别名永久生效

### 每次登录自动生效

> 把别名加在 `/etc/profile` 或 `~/.bashrc` 中; 然后  `source ~/.bashrc`

### 让每一位用户都生效

> 把别名加在 `/etc/bashrc` 最后面; 然后 `source /etc/bashrc` 

