 `delta`、 `Apache Iceberg` 、`Apache Hudi`

[开源数据湖方案选型：Hudi、Delta、Iceberg深度对比_delta (sohu.com)](https://www.sohu.com/a/403477409_411876)

`delta` 需求：

![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202202281048122.png)

delta核心功能特性：

![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202202281050108.png)

Hudi核心特性：

![image-20220228105254680](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202202281524612.png)



`Iceberg` 核心诉求:

![image-20220228105455152](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202202281524757.png)



综上，一个**好的数据湖**应该做到的功能点：

![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202202281055342.png)

<table border="1">
<tr>
<th></th>
<th>Item</th>    
<th>delta</th>
<th>Iceberg</th>
<th>Hudi</th>    
</tr>
<tr>
<th rowspan="4">Github</th>
<td>Watch</td>
<td>187</td>
<td>129</td>
<td>1.2k</td>    
</tr>
<tr>
<td>Fork</td>
<td>964</td>
<td>980</td>    
<td>1.2k</td>    
</tr>
<tr>
<td>Star</td>
<td>4.1k</td>
<td>2.5k</td>    
<td>2.8k</td>    
</tr>
<tr>
<td>Issues</td>
<td>146</td>
<td>680</td>    
<td>74</td>    
</tr>
<tr>
<th rowspan="4">ACID和隔离级别支持</th>
<td>ACID</td>
<td>✔</td>
<td>✔</td>
<td>✔</td> 
</tr>
<tr>
<td>隔离级别</td>
<td>Serialization<br>Write Serialization<br>Snapshot Isolation</td>
<td>Write Serialization</td>
<td>Snapshot Isolation</td> 
</tr>
<tr>
<td>多个writer并发</td>
<td>✔</td>
<td>✔</td>
<td>✔</td> 
</tr>
<td>Time Travel</td>
<td>✔</td>
<td>✔</td>
<td>✔</td> 
</tr>
<tr>
<th rowspan="2">Schema变更支持和设计</th>
<td>Schema Evolution</td>
<td>all</td>
<td>all</td>
<td>back-compatible</td> 
</tr>
<td>Self-defined schema object</td>
<td>❌(spark-schema)</td>
<td>✔</td>
<td>❌(spark-schema)</td> 
</tr>
<tr>
<th rowspan="4">流批接口支持</th>
<td>Batch Read</td>
<td>✔(hive/spark/presto)</td>
<td>✔(pig/spark)hive?</td>
<td>✔(RO-view;hive/spark/presto)</td>
</tr>
<tr>
<td>Batch Write</td>
<td>✔(spark)</td>
<td>✔(spark)</td>
<td>✔(spark)</td>
</tr>
<tr>
<td>Streaming Read</td>
<td>✔</td>
<td>✔</td>
<td>✔</td>
</tr>
<tr>
<td>Streaming Write</td>
<td>✔</td>
<td>✔</td>
<td>✔</td>
</tr>
<tr>
<th rowspan="4">接口抽象程度和插件化</th>
<td>Engine Pluggable(Write Path)</td>
<td>❌(Bind with spark)</td>
<td>✔</td>
<td>❌(Bind with spark)</td>
</tr>
<tr>
<td>Engine Pluggable(Read Path)</td>
<td>✔</td>
<td>✔</td>
<td>✔</td>
</tr>
<tr>
<td>Storage Pluggable(Less Storage API Binding)</td>
<td>✔</td>
<td>✔</td>
<td>✔</td>
</tr>
<tr>
<td>Open File Format</td>
<td>✔</td>
<td>✔</td>
<td>✔(Data) + ❌(Log)</td>
</tr>
<tr>
<th rowspan="6">查询性能优化</th>
<td>Filter PushDown</td>
<td>❌</td>
<td>✔</td>
<td>❌</td>
</tr>
<tr>
<td>Low meta cost</td>
<td>✔</td>
<td>✔</td>
<td>✔</td>
</tr>
<tr>
<td>Index within partitions<br>(Boost the perf of selective queries)</td>
<td>-</td>
<td>✔</td>
<td>-</td>
</tr>
<tr>
<td>CopyOnWrite</td>
<td>✔</td>
<td>✔</td>
<td>✔</td>
</tr>
<tr>
<td>MergeOnRead</td>
<td>❌</td>
<td>On-going ?</td>
<td>✔</td>
</tr>
<tr>
<td>Auto-Compaction</td>
<td>❌</td>
<td>❌</td>
<td>✔</td>
</tr>
<tr>
<th rowspan="4">其他功能</th>
<td>One line demo</td>
<td>Good</td>
<td>Not Good</td>
<td>Medium</td>
</tr>
<tr>
<td>Python Support</td>
<td>✔</td>
<td>✔</td>
<td>❌</td>
</tr>
<tr>
<td>File Encryption</td>
<td>❌</td>
<td>✔</td>
<td>❌</td>
</tr>
<tr>
<td>Cli Command</td>
<td>✔</td>
<td>❌</td>
<td>✔</td>
</tr>
</table>


> ::
> `group` 修饰符只能在比较和数学运算符中使用。在逻辑运算 `and`，`unless` 和 `or` 操作中默认与右向量中的所有元素进行匹配。

> **:memo:** 说明 
> &nbsp; &nbsp; &nbsp; **三种隔离:**
>  -  Serialization是说所有的reader和writer都必须串行执行；
>
>  -  Write Serialization: 是说多个writer必须严格串行，reader和writer之间则可以同时跑；
>
>  -  Snapshot Isolation: 是说如果多个writer写的数据无交集，则可以并发执行；否则只能串行。Reader和writer可以同时跑。
>  
> &nbsp; &nbsp; &nbsp; 综合起来看，Snapshot Isolation隔离级别的并发性是相对比较好的
>
> &nbsp; &nbsp; &nbsp; `One line demo`指的是：示例demo是否足够简单，体现了方案的易用性，Iceberg稍微复杂一点
> &nbsp; &nbsp; &nbsp; Python支持其实是很多基于数据湖之上做机器学习的开发者会考虑的问题



总结：

![](https://cdn.jsdelivr.net/gh/vinloong/imgchr@latest/notes/img/202202281516783.png)





Delta 与 Spark 牢牢绑定

Iceberg 基础扎实，扩展灵活方便

Hudi 基础设计不够扎实，但是功能较完善
