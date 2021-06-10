---
title: Linux 中常用的命令
date: 2020-09-28
categories: 
    - linux
tags: [linux, linux command]
---


# 终端快捷键
- **`CTRL+U`** : 从光标处删除文本直到行首
- **`CTRL+K`** : 从光标处删除文本直到行尾
- **`CTRL+Y`** : 粘贴文本
- **`CTRL+E`** : 将光标移动到行尾
- **`CTRL+A`** : 将光标移动到行的开头
- **`ALT+F`** : 光标移动到后一个单词
- **`ALT+B`** : 光标移动到前一个单词
- **`CTRL+W`** : 剪切光标前面的字符至上一个空格处
- **`Shift+Insert`** : 将文本粘贴到终端中

<!--more-->

```bash
# 每当您输入一个命令，并且出现权限不够的时候,使用 "sudo !!"

# 安装软件以root身份安装，这时会提示权限不够
$ apt-get install vlc

# 就会以sudo的形式运行前面的命令
$ sudo !!

```

# 一、文件和目录

## 1. `cd`

> `change directory`,用于切换当前目录，它的参数是要切换到的目录的路径，可以是绝对路径，也可以是相对路径

```bash
# 进入 '/ home' 目录
$ cd /home    

# 返回上一级目录
$ cd ..

# 返回上两级目录
$ cd ../..

# 进入当前用户的主目录 
$ cd

# 进入当前用户的主目录
$ cd ~

# 进入{$user}的主目录
$ cd ~{$user}

# 返回上次所在的目录
$ cd - 
```

## 2. `pwd`

> `print working directory`,显示当前的工作路径
```bash
> pwd
/etc/netplan
```

## 3. `ls`

> `list`,查看文件与目录的命令

```bash
# 查看目录中的文件和目录
$ ls 

# 显示文件和目录的详细资料
$ ls -l

# 列出全部文件，包含隐藏文件
$ ls -a

# 连同子目录的内容一起列出（递归列出），等于该目录下的所有文件都会显示出来  
$ ls -R

# 显示包含数字的文件名和目录名
$ ls [0-9]

# 查找当前目录中的所有jar文件
> ls -l | grep '.jar'

```

## 4. `cp`

> `copy`,用于复制文件，可以把多个文件一次性地复制到一个目录下

部分参数说明：
> `-a` ：将文件的特性一起复制
> `-p` ：连同文件的属性一起复制，而非使用默认方式，与-a相似，常用于备份
> `-i` ：若目标文件已经存在时，在覆盖时会先询问操作的进行
> `-r` ：递归持续复制，用于目录的复制行为
> `-u` ：目标文件与源文件有差异时才会复制

```bash

# 复制文件
cp ${source} ${dest}

# 递归复制整个文件夹
cp -r ${sourceFolder} ${targetFolder}

# 远程拷贝
scp ${sourecFile} ${romoteUserName}@${remoteIp}:${remoteAddr}

```

## 5. `mv`

> `move`，用于移动文件、目录或更名

部分参数说明：

> `-f` ：force强制的意思，如果目标文件已经存在，不会询问而直接覆盖
> `-i` ：若目标文件已经存在，就会询问是否覆盖
> `-u` ：若目标文件已经存在，且比目标文件新，才会更新

```bash

mv ${temp/movefile} ${targetFolder}

mv ${oldNameFile} ${newNameFile}

```

## 6. `rm`

> `remove`，用于删除文件或目录

部分参数说明：

> `-f` ：就是force的意思，忽略不存在的文件，不会出现警告消息
> `-i` ：互动模式，在删除前会询问用户是否操作
> `-r` ：递归删除，最常用于目录删除

# 二、查看和查找文件

## 1. `cat`

> 用于查看文本文件的内容，后接要查看的文件名，通常可用管道与more和less一起使用

```bash
# 从第一个字节开始正向查看文件的内容 
$ cat file1

# 从最后一行开始反向查看一个文件的内容 
$ tac file1 

# 标示文件的行数 
$ cat -n file1

# 查看一个长文件的内容
$ more file1  

# 查看一个文件的前两行 
$ head -n 2 file1 

# 查看一个文件的最后两行 
$ tail -n 2 file1

# 从1000行开始显示，显示1000行以后的
$ tail -n +1000 file1 

# 这个命令会自动显示新增内容
$ tail -f exmaple.log 

# 显示1000行到3000行
$ cat filename | head -n 3000 | tail -n +1000 

# 从第3000行开始，显示1000(即显示3000~3999行)
$ cat filename | tail -n +3000 | head -n 1000 
```

## 2. `find`

> 用来查找系统的

```bash
# 从 '/' 开始进入根文件系统搜索文件和目录 
> find / -name file1

# 搜索属于用户 'user1' 的文件和目录 
> find / -user user1

# 搜索在过去100天内未被使用过的执行文件 
> find /usr/bin -type f -atime +100

# 搜索在10天内被创建或者修改过的文件 
> find /usr/bin -type f -mtime -10

# 根据名称查找/目录下的filename.txt文件
> find / -name filename.txt 

# 递归查找所有的xml文件
> find . -name "*.xml"

# 递归查找所有文件内容中包含 'hello world' 的xml文件
> find . -name "*.xml" |xargs grep "hello world" 
```

```bash
# 查找所以有的包含spring的xml文件
> grep -H 'spring' *.xml 

# 显示所有以d开头的文件中包含test的行
> grep 'test' d* 

# 显示在aa，bb，cc文件中匹配test的行
> grep 'test' aa bb cc 
 
 # 显示所有包含每个字符串至少有5个连续小写字符的字符串的行
> grep '[a-z]\{5\}' aa 

```

```bash
# 显示一个二进制文件、源码或man的位置 
> whereis bash

# 显示一个二进制文件或可执行文件的完整路径
> which bash
```

```bash
# 删除大于50M的文件
> find /var/mail/ -size +50M -exec rm {} \;

#  删除文件大小为零的文件
> find ./ -size 0 | xargs rm -f &

```

# 三、权限

## 1. `chmod`

> 改变文件和文件夹的权限

```bash
# 显示权限 
$ ls -lh

# 设置目录的所有人(u)、群组(g)以及其他人(o)以读（r，4 ）、写(w，2)和执行(x，1)的权限 
> chmod ugo+rwx directory1

# 删除群组(g)与其他人(o)对目录的读写执行权限
> chmod go-rwx directory1

```

## 2. `chown`

> 改变文件的所有者

```bash
# 改变一个文件的所有人属性 
> chown user1 file1

# 改变一个目录的所有人属性并同时改变改目录下所有文件的属性 
> chown -R user1 directory1

# 改变一个文件的所有人和群组属性
> chown user1:group1 file1
```

## 3. `chgrp`

> 改变文件所属用户组

```bash
# 改变文件的群组
> chgrp group1 file1
```

# 四、文本处理

## 1. `grep`

> 分析一行的信息，若当中有我们所需要的信息，就将该行显示出来，
> 该命令通常与管道命令一起使用，用于对一些命令的输出进行筛选加工等等

```bash
# 在文件 '/var/log/messages'中查找关键词"Aug"
$ grep Aug /var/log/messages

# 在文件 '/var/log/messages'中查找以"Aug"开始的词汇 
$ grep ^Aug /var/log/messages

# 选择 '/var/log/messages' 文件中所有包含数字的行 
$ grep [0-9]  /var/log/messages

# 在目录 '/var/log' 及随后的目录中搜索字符串"Aug" 
$ grep Aug -R /var/log/*

# 将example.txt文件中的 "string1" 替换成 "string2" 
$ sed 's/stringa1/stringa2/g' example.txt

# 从example.txt文件中删除所有空白行
$ sed '/^$/d' example.txt

```

## 2. `paste`

```bash
# 合并两个文件或两栏的内容 
$ paste file1 file2

# 合并两个文件或两栏的内容，中间用"+"区分
$ paste -d '+' file1 file2
```


## 3. `sort`

```bash
# 排序两个文件的内容 
$ sort file1 file2

# 取出两个文件的并集(重复的行只保留一份) 
$ sort file1 file2 | uniq

# 删除交集，留下其他的行 
$ sort file1 file2 | uniq -u

# 取出两个文件的交集(只留下同时存在于两个文件中的文件)
$ sort file1 file2 | uniq -d
```

## 4. `comm`

```bash
# 比较两个文件的内容只删除 'file1' 所包含的内容
$ comm -1 file1 file2

# 比较两个文件的内容只删除 'file2' 所包含的内容 
$ comm -2 file1 file2

# 比较两个文件的内容只删除两个文件共有的部分
$ comm -3 file1 file2
```

# 五、压缩和解压缩

## 1. `tar`

> 对文件进行打包，默认情况并不会压缩，如果指定了相应的参数，
> 它还会调用相应的压缩程序（如gzip和bzip等）进行压缩和解压

部分参数说明：

> `-c` ：新建打包文件  
> `-t` ：查看打包文件的内容含有哪些文件名  
> `-x` ：解打包或解压缩的功能，可以搭配-C（大写）指定解压的目录，注意-c,-t,-x不能同时出现在同一条命令中   
> `-j` ：通过bzip2的支持进行压缩/解压缩    
> `-z` ：通过gzip的支持进行压缩/解压缩
> `-v` ：在压缩/解压缩过程中，将正在处理的文件名显示出来
> `-f filename` ：filename为要处理的文件
> `-C dir` ：指定压缩/解压缩的目录dir

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

```bash
# 解压一个叫做 'file1.bz2'的文件 
$ bunzip2 file1.bz2

# 压缩一个叫做 'file1' 的文件 
$ bzip2 file1

# 解压一个叫做 'file1.gz'的文件 
$ gunzip file1.gz

# 压缩一个叫做 'file1'的文件 
$ gzip file1

# 最大程度压缩 
$ gzip -9 file1

# 创建一个叫做 'file1.rar' 的包 
$ rar a file1.rar test_file

# 同时压缩 'file1', 'file2' 以及目录 'dir1'
$ rar a file1.rar file1 file2 dir1 

# 解压rar包
$ rar x file1.rar

# 创建一个zip格式的压缩包 
$ zip file1.zip file1

# 解压一个zip格式压缩包 
$ unzip file1.zip

# 将几个文件和目录同时压缩成一个zip格式的压缩包
$ zip -r file1.zip file1 file2 dir1
```


# 六、 关机和重启

```bash

# 关闭系统
> shutdown -h now

# 关闭系统
> init 0

# 关闭系统
> telinit 0 

# 按预定时间关闭系统
shutdown -h hours:minutes & 

# 取消按预定时间关闭系统
shutdown -c

# 重启
shutdown -r now  

# 重启
reboot 

# 注销 
logout 

# 测算一个命令（即程序）的执行时间 
time 

```

# 七、进程相关

## 1. `jps`
> 显示当前系统的java进程情况，及其id号

## 2. `ps`

> `process`,  用于将某个时间点的进程运行情况选取下来并输出

> 部分参数说明：
> `-A` ：所有的进程均显示出来
> `-a` ：不与terminal有关的所有进程
> `-u` ：有效用户的相关进程
> `-x` ：一般与a参数一起使用，可列出较完整的信息
> `-l` ：较长，较详细地将PID的信息列出

```bash
# 查看系统所有的进程数据
> ps aux

# 查看不与terminal有关的所有进程
> ps ax 

# 查看系统所有的进程数据
> ps -lA 

# 查看连同一部分进程树状态
> ps axjf 

# 查看所有有关mono的进程
> ps –ef|grep mono

# 查看jexus进程
> ps aux|grep jexus

```

## 3. `kill`

> 部分参数：

> `-l`: 信号，若果不加信号的编号参数，则使用“-l”参数会列出全部的信号名称  
> `-a`: 当处理当前进程时，不限制命令名和进程号的对应关系  
> `-p`: 指定kill 命令只打印相关进程的进程号，而不发送任何信号  
> `-s`: 指定发送信号  
> `-u`: 指定用户  

```bash
# 列出所有信号名称
> kill -l
 1) SIGHUP	    2) SIGINT	    3) SIGQUIT	    4) SIGILL	    5) SIGTRAP
 6) SIGABRT	    7) SIGBUS	    8) SIGFPE	    9) SIGKILL	    10) SIGUSR1
11) SIGSEGV	    12) SIGUSR2	    13) SIGPIPE	    14) SIGALRM	    15) SIGTERM
16) SIGSTKFLT	17) SIGCHLD	    18) SIGCONT	    19) SIGSTOP	    20) SIGTSTP
21) SIGTTIN	    22) SIGTTOU	    23) SIGURG	    24) SIGXCPU	    25) SIGXFSZ
26) SIGVTALRM	27) SIGPROF	    28) SIGWINCH	29) SIGIO	    30) SIGPWR
31) SIGSYS	    34) SIGRTMIN	35) SIGRTMIN+1	36) SIGRTMIN+2	37) SIGRTMIN+3
38) SIGRTMIN+4	39) SIGRTMIN+5	40) SIGRTMIN+6	41) SIGRTMIN+7	42) SIGRTMIN+8
43) SIGRTMIN+9	44) SIGRTMIN+10	45) SIGRTMIN+11	46) SIGRTMIN+12	47) SIGRTMIN+13
48) SIGRTMIN+14	49) SIGRTMIN+15	50) SIGRTMAX-14	51) SIGRTMAX-13	52) SIGRTMAX-12
53) SIGRTMAX-11	54) SIGRTMAX-10	55) SIGRTMAX-9	56) SIGRTMAX-8	57) SIGRTMAX-7
58) SIGRTMAX-6	59) SIGRTMAX-5	60) SIGRTMAX-4	61) SIGRTMAX-3	62) SIGRTMAX-2
63) SIGRTMAX-1	64) SIGRTMAX
```

> 其中只有第9种信号(SIGKILL)才可以无条件终止进程：
```text
HUP    1    终端断线
INT     2    中断（同 Ctrl + C）
QUIT    3    退出（同 Ctrl + \）
TERM   15    终止
KILL    9    强制终止
CONT   18    继续（与STOP相反， fg/bg命令）
STOP    19    暂停（同 Ctrl + Z）
```


```bash
# 查找进程并用kill杀掉
> ps -ef|grep vim 
root      3268  2884  0 16:21 pts/1    00:00:00 vim install.log
root      3370  2822  0 16:21 pts/0    00:00:00 grep vim
> kill 3268 

# -9 强制杀掉进程
> kill –9 3268   
```

## 4. `killall`

> 命令参数：
```text
-Z 只杀死拥有scontext 的进程
-e 要求匹配进程名称
-I 忽略小写
-g 杀死进程组而不是进程
-i 交互模式，杀死进程前先询问用户
-l 列出所有的已知信号名称
-q 不输出警告信息
-s 发送指定的信号
-v 报告信号是否成功发送
-w 等待进程死亡
--help 显示帮助信息
--version 显示版本显示
```

```bash
# 杀死所有同名进程
> killall nginx
> killall -9 bash

# 向进程发送指定信号
> killall -TERM ngixn  
# 或者  
> killall -KILL nginx
```

```bash
# 如何杀死进程：

# -9表示强制关闭
> kill -9 pid  

> killall -9 ${pro-name}

> pkill ${pro-name}
```

## 5. `top`

> 能够实时显示系统中各个进程的资源占用状况



---
> 查看端口占用

```bash
> netstat -tunlp|grep ${port}

# 查看端口属于哪个程序
> lsof -i :8080
```

