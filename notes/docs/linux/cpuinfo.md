查看CPU信息

```bash
cat /proc/cpuinfo
```

> 判断有几个物理CPU/几核/几线程
>
> 判断依据：
>
> 1.具有相同core id的cpu是同一个core的超线程
>
> 2.具有相同physical id的cpu是同一颗cpu封装的线程或者cores

```bash
# 逻辑CPU个数
cat /proc/cpuinfo | grep "processor" | wc -l

# 物理CPU个数
cat /proc/cpuinfo | grep "physical id" | sort -u | wc -l

# 每个物理CPU中Core的个数
cat /proc/cpuinfo | grep "cpu cores" | uniq | awk -F: '{print $2}'

# 查看core id的数量,即为所有物理CPU上的core的个数
cat /proc/cpuinfo | grep "core id" | uniq |  wc -l


```



> /proc/cpuinfo 文件包含系统上每个处理器的数据段落。/proc/cpuinfo 描述中有 6 个条目适用于多内核和超线程（HT）技术检查：processor, vendor id, physical id, siblings, core id 和 cpu cores。

> processor 条目包括这一逻辑处理器的唯一标识符。

> physical id 条目包括每个物理封装的唯一标识符。

> core id 条目保存每个内核的唯一标识符。

> siblings 条目列出了位于相同物理封装中的逻辑处理器的数量。

> cpu cores 条目包含位于相同物理封装中的内核数量。

> 如果处理器为英特尔处理器，则 vendor id 条目中的字符串是 GenuineIntel。



> 1.拥有相同 physical id 的所有逻辑处理器共享同一个物理插座。每个 physical id 代表一个唯一的物理封装。

> 2.Siblings 表示位于这一物理封装上的逻辑处理器的数量。它们可能支持也可能不支持超线程（HT）技术。

> 3.每个 core id 均代表一个唯一的处理器内核。所有带有相同 core id 的逻辑处理器均位于同一个处理器内核上。

> 4.如果有一个以上逻辑处理器拥有相同的 core id 和 physical id，则说明系统支持超线程（HT）技术。

> 5.如果有两个或两个以上的逻辑处理器拥有相同的 physical id，但是 core id 不同，则说明这是一个多内核处理器。cpu cores 条目也可以表示是否支持多内核。