

# 数据类型

在 Prometheus 的表达式语言中，表达式或子表达式包括以下四种类型之一：

- **瞬时向量（Instant vector）** - 一组时间序列，每个时间序列包含单个样本，它们共享相同的时间戳。也就是说，表达式的返回值中只会包含该时间序列中的最新的一个样本值。而相应的这样的表达式称之为**瞬时向量表达式**。
- **区间向量（Range vector）** - 一组时间序列，每个时间序列包含一段时间范围内的样本数据。
- **标量（Scalar）** - 一个浮点型的数据值。
- **字符串（String）** - 一个简单的字符串值。

# 字面量

## 字符串

字符串可以用单引号、双引号或反引号指定为文字常量。

PromQL 遵循与 Go 相同的转义规则。在单引号或双引号中，用反斜杠来表示转义序列，后面可以跟 `a`, `b`, `f`, `n`, `r`, `t`, `v` 或 `\`。特殊字符可以使用八进制（`\nnn`）或者十六进制（`\xnn`，`\unnnn` 和 `\Unnnnnnnn`）。

与 Go 不同，Prometheus 不会对反引号内的换行符进行转义。

```
"this is a string"
'these are unescaped: \n \\ \t'
`these are not unescaped: \n ' " \t`
```

## 标量

标量浮点值可以字面上写成 `[-](digits)[.(digits)]` 的形式。

```
-2.43
```

# 时间序列过滤器

## 瞬时向量过滤器

瞬时向量过滤器允许在指定的时间戳内选择一组时间序列和每个时间序列的单个样本值。在最简单的形式中，近指定指标（metric）名称。这将生成包含此指标名称的所有时间序列的元素的瞬时向量。

例如：选择指标名称为 `http_requests_total` 的所有时间序列：

```
http_requests_total
```

可以通过向花括号（`{}`）里附加一组标签来进一步过滤时间序列。

例如：选择指标名称为 `http_requests_total`，`job` 标签值为 `prometheus`，`group` 标签值为 `canary` 的时间序列：

```
http_requests_total{job="prometheus",group="canary"}
```

PromQL 还支持用户根据时间序列的标签匹配模式来对时间序列进行过滤，目前主要支持两种匹配模式：完全匹配和正则匹配。总共有以下几种标签匹配运算符：

- `=` : 选择与提供的字符串完全相同的标签。
- `!=` : 选择与提供的字符串不相同的标签。
- `=~` : 选择正则表达式与提供的字符串（或子字符串）相匹配的标签。
- `!~` : 选择正则表达式与提供的字符串（或子字符串）不匹配的标签。

例如：选择指标名称为 `http_requests_total`，环境为 `staging`、`testing` 或 `development`，HTTP 方法为 `GET` 的时间序列：

```
http_requests_total{environment=~"staging|testing|development",method!="GET"}
```

没有指定标签的标签过滤器会选择该指标名称的所有时间序列。

所有的 PromQL 表达式必须至少包含一个指标名称，或者一个不会匹配到空字符串的标签过滤器。

以下表达式是非法的（因为会匹配到空字符串）：

```
{job=~".*"} # 非法！
```

以下表达式是合法的：

```
{job=~".+"}              # 合法！
{job=~".*",method="get"} # 合法！
```

除了使用 `<metric name>{label=value}` 的形式以外，我们还可以使用内置的 `__name__` 标签来指定监控指标名称。例如：表达式 `http_requests_total` 等效于 `{__name__="http_requests_total"}`。也可以使用除 `=` 之外的过滤器（`=`，`=~`，`~`）。以下表达式选择指标名称以 `job:` 开头的所有指标：

```
{__name__=~"job:.*"}
```



## 区间向量过滤器

区间向量与瞬时向量的工作方式类似，唯一的差异在于在区间向量表达式中我们需要定义时间选择的范围，时间范围通过时间范围选择器 `[]` 进行定义，以指定应为每个返回的区间向量样本值中提取多长的时间范围。

时间范围通过数字来表示，单位可以使用以下其中之一的时间单位：

- `s` - 秒
- `m` - 分钟
- `h` - 小时
- `d` - 天
- `w` - 周
- `y` - 年

例如：选择在过去 5 分钟内指标名称为 `http_requests_total`，`job` 标签值为 `prometheus` 的所有时间序列：

```
http_requests_total{job="prometheus"}[5m]
```

## 时间位移操作

在瞬时向量表达式或者区间向量表达式中，都是以当前时间为基准：

```
http_request_total{} # 瞬时向量表达式，选择当前最新的数据
http_request_total{}[5m] # 区间向量表达式，选择以当前时间为基准，5分钟内的数据
```

而如果我们想查询，5 分钟前的瞬时样本数据，或昨天一天的区间内的样本数据呢? 这个时候我们就可以使用位移操作，位移操作的关键字为 `offset`。

例如，以下表达式返回相对于当前查询时间过去 5 分钟的 `http_requests_total` 值：

```
http_requests_total offset 5m
```

**注意：**`offset` 关键字需要紧跟在选择器（`{}`）后面。以下表达式是正确的：

```
sum(http_requests_total{method="GET"} offset 5m) // GOOD.
```

下面的表达式是不合法的：

```
sum(http_requests_total{method="GET"}) offset 5m // INVALID.
```

该操作同样适用于区间向量。以下表达式返回指标 `http_requests_total` 一周前的 5 分钟之内的 HTTP 请求量的增长率:

```
rate(http_requests_total[5m] offset 1w)
```

# 操作符

使用PromQL除了能够方便的按照查询和过滤时间序列以外，PromQL还支持丰富的操作符，用户可以使用这些操作符对进一步的对事件序列进行二次加工。这些操作符包括：数学运算符，逻辑运算符，布尔运算符等等。

## 二元运算符

Prometheus 的查询语言支持基本的逻辑运算和算术运算。对于两个瞬时向量, 匹配行为可以被改变。

### 算术二元运算符

在 Prometheus 系统中支持下面的二元算术运算符：

- `+` 加法
- `-` 减法
- `*` 乘法
- `/` 除法
- `%` 模
- `^` 幂等

二元运算操作符支持 `scalar/scalar(标量/标量)`、`vector/scalar(向量/标量)`、和 `vector/vector(向量/向量)` 之间的操作。

在两个标量之间进行数学运算，得到的结果也是标量。

在向量和标量之间，这个运算符会作用于这个向量的每个样本值上。例如：如果一个时间序列瞬时向量除以 2，操作结果也是一个新的瞬时向量，且度量指标名称不变, 它是原度量指标瞬时向量的每个样本值除以 2。

如果是瞬时向量与瞬时向量之间进行数学运算时，过程会相对复杂一点，运算符会依次找到与左边向量元素匹配（标签完全一致）的右边向量元素进行运算，如果没找到匹配元素，则直接丢弃。同时新的时间序列将不会包含指标名称。

例如，如果我们想根据 `node_disk_bytes_written` 和 `node_disk_bytes_read` 获取主机磁盘IO的总量，可以使用如下表达式：

```
node_disk_bytes_written + node_disk_bytes_read
```

该表达式返回结果的示例如下所示：

```
{device="sda",instance="localhost:9100",job="node_exporter"}=>1634967552@1518146427.807 + 864551424@1518146427.807
{device="sdb",instance="localhost:9100",job="node_exporter"}=>0@1518146427.807 + 1744384@1518146427.807
```

### 布尔运算符

目前，Prometheus 支持以下布尔运算符：

- `==` (相等)
- `!=` (不相等)
- `>` (大于)
- `<` (小于)
- `>=` (大于等于)
- `<=` (小于等于)

布尔运算符被应用于 `scalar/scalar（标量/标量）`、`vector/scalar（向量/标量）`，和`vector/vector（向量/向量）`。默认情况下布尔运算符只会根据时间序列中样本的值，对时间序列进行过滤。我们可以通过在运算符后面使用 `bool` 修饰符来改变布尔运算的默认行为。使用 bool 修改符后，布尔运算不会对时间序列进行过滤，而是直接依次瞬时向量中的各个样本数据与标量的比较结果 `0` 或者 `1`。

在两个标量之间进行布尔运算，必须提供 bool 修饰符，得到的结果也是标量，即 `0`（`false`）或 `1`（`true`）。例如：

```
2 > bool 1 # 结果为 1
```

瞬时向量和标量之间的布尔运算，这个运算符会应用到某个当前时刻的每个时序数据上，如果一个时序数据的样本值与这个标量比较的结果是 `false`，则这个时序数据被丢弃掉，如果是 `true`, 则这个时序数据被保留在结果中。如果提供了 bool 修饰符，那么比较结果是 `0` 的时序数据被丢弃掉，而比较结果是 `1` 的时序数据被保留。例如：

```
http_requests_total > 100 # 结果为 true 或 false
http_requests_total > bool 100 # 结果为 1 或 0
```

瞬时向量与瞬时向量直接进行布尔运算时，同样遵循默认的匹配模式：依次找到与左边向量元素匹配（标签完全一致）的右边向量元素进行相应的操作，如果没找到匹配元素，或者计算结果为 false，则直接丢弃。如果匹配上了，则将左边向量的度量指标和标签的样本数据写入瞬时向量。如果提供了 bool 修饰符，那么比较结果是 `0` 的时序数据被丢弃掉，而比较结果是 `1` 的时序数据（只保留左边向量）被保留。

### 集合运算符

使用瞬时向量表达式能够获取到一个包含多个时间序列的集合，我们称为瞬时向量。 通过集合运算，可以在两个瞬时向量与瞬时向量之间进行相应的集合操作。目前，Prometheus 支持以下集合运算符：

- `and` (并且)
- `or` (或者)
- `unless` (排除)

**vector1 and vector2** 会产生一个由 `vector1` 的元素组成的新的向量。该向量包含 vector1 中完全匹配 `vector2` 中的元素组成。

**vector1 or vector2** 会产生一个新的向量，该向量包含 `vector1` 中所有的样本数据，以及 `vector2` 中没有与 `vector1` 匹配到的样本数据。

**vector1 unless vector2** 会产生一个新的向量，新向量中的元素由 `vector1` 中没有与 `vector2` 匹配的元素组成。



## 匹配模式

向量与向量之间进行运算操作时会基于默认的匹配规则：依次找到与左边向量元素匹配（标签完全一致）的右边向量元素进行运算，如果没找到匹配元素，则直接丢弃。

接下来将介绍在 PromQL 中有两种典型的匹配模式：一对一（one-to-one）,多对一（many-to-one）或一对多（one-to-many）。

### 一对一匹配

一对一匹配模式会从操作符两边表达式获取的瞬时向量依次比较并找到唯一匹配(标签完全一致)的样本值。默认情况下，使用表达式：

```
vector1 <operator> vector2
```

在操作符两边表达式标签不一致的情况下，可以使用 `on(label list)` 或者 `ignoring(label list）`来修改便签的匹配行为。使用 `ignoreing` 可以在匹配时忽略某些便签。而 `on` 则用于将匹配行为限定在某些便签之内。

```
<vector expr> <bin-op> ignoring(<label list>) <vector expr>
<vector expr> <bin-op> on(<label list>) <vector expr>
```

例如当存在样本：

```
method_code:http_errors:rate5m{method="get", code="500"}  24
method_code:http_errors:rate5m{method="get", code="404"}  30
method_code:http_errors:rate5m{method="put", code="501"}  3
method_code:http_errors:rate5m{method="post", code="500"} 6
method_code:http_errors:rate5m{method="post", code="404"} 21

method:http_requests:rate5m{method="get"}  600
method:http_requests:rate5m{method="del"}  34
method:http_requests:rate5m{method="post"} 120
```

使用 PromQL 表达式：

```
method_code:http_errors:rate5m{code="500"} / ignoring(code) method:http_requests:rate5m
```

该表达式会返回在过去 5 分钟内，HTTP 请求状态码为 500 的在所有请求中的比例。如果没有使用 `ignoring(code)`，操作符两边表达式返回的瞬时向量中将找不到任何一个标签完全相同的匹配项。

因此结果如下：

```
{method="get"}  0.04            //  24 / 600
{method="post"} 0.05            //   6 / 120
```

同时由于 method 为 `put` 和 `del` 的样本找不到匹配项，因此不会出现在结果当中。

### 多对一和一对多

多对一和一对多两种匹配模式指的是“一”侧的每一个向量元素可以与"多"侧的多个元素匹配的情况。在这种情况下，必须使用 group 修饰符：`group_left` 或者 `group_right` 来确定哪一个向量具有更高的基数（充当“多”的角色）。

```
<vector expr> <bin-op> ignoring(<label list>) group_left(<label list>) <vector expr>
<vector expr> <bin-op> ignoring(<label list>) group_right(<label list>) <vector expr>
<vector expr> <bin-op> on(<label list>) group_left(<label list>) <vector expr>
<vector expr> <bin-op> on(<label list>) group_right(<label list>) <vector expr>
```

多对一和一对多两种模式一定是出现在操作符两侧表达式返回的向量标签不一致的情况。因此需要使用 ignoring 和 on 修饰符来排除或者限定匹配的标签列表。

例如，使用表达式：

```
method_code:http_errors:rate5m / ignoring(code) group_left method:http_requests:rate5m
```

该表达式中，左向量 `method_code:http_errors:rate5m` 包含两个标签 `method` 和 `code`。而右向量 `method:http_requests:rate5m` 中只包含一个标签 `method`，因此匹配时需要使用 `ignoring` 限定匹配的标签为 `code`。 在限定匹配标签后，右向量中的元素可能匹配到多个左向量中的元素 因此该表达式的匹配模式为多对一，需要使用 group 修饰符 `group_left` 指定左向量具有更好的基数。

最终的运算结果如下：

```
{method="get", code="500"}  0.04            //  24 / 600
{method="get", code="404"}  0.05            //  30 / 600
{method="post", code="500"} 0.05            //   6 / 120
{method="post", code="404"} 0.175           //  21 / 120
```

> **:warning:  提醒**
> `group` 修饰符只能在比较和数学运算符中使用。在逻辑运算 `and`，`unless` 和 `or` 操作中默认与右向量中的所有元素进行匹配。

## 聚合操作

Prometheus 还提供了下列内置的聚合操作符，这些操作符作用域瞬时向量。可以将瞬时表达式返回的样本数据进行聚合，形成一个具有较少样本值的新的时间序列。

- `sum` (求和)
- `min` (最小值)
- `max` (最大值)
- `avg` (平均值)
- `stddev` (标准差)
- `stdvar` (标准差异)
- `count` (计数)
- `count_values` (对 value 进行计数)
- `bottomk` (样本值最小的 k 个元素)
- `topk` (样本值最大的k个元素)
- `quantile` (分布统计)

这些操作符被用于聚合所有标签维度，或者通过 `without` 或者 `by` 子语句来保留不同的维度。

```
<aggr-op>([parameter,] <vector expression>) [without|by (<label list>)]
```

其中只有 `count_values`, `quantile`, `topk`, `bottomk` 支持参数(parameter)。

`without` 用于从计算结果中移除列举的标签，而保留其它标签。`by` 则正好相反，结果向量中只保留列出的标签，其余标签则移除。通过 without 和 by 可以按照样本的问题对数据进行聚合。

例如：

如果指标 `http_requests_total` 的时间序列的标签集为 `application`, `instance`, 和 `group`，我们可以通过以下方式计算所有 instance 中每个 application 和 group 的请求总量：

```
sum(http_requests_total) without (instance)
```

等价于：

```
 sum(http_requests_total) by (application, group)
```

如果只需要计算整个应用的 HTTP 请求总量，可以直接使用表达式：

```
sum(http_requests_total)
```

`count_values` 用于时间序列中每一个样本值出现的次数。count_values 会为每一个唯一的样本值输出一个时间序列，并且每一个时间序列包含一个额外的标签。这个标签的名字由聚合参数指定，同时这个标签值是唯一的样本值。

例如要计算运行每个构建版本的二进制文件的数量：

```
count_values("version", build_version)
```

返回结果如下：

```
{count="641"}   1
{count="3226"}  2
{count="644"}   4
```

`topk` 和 `bottomk` 则用于对样本值进行排序，返回当前样本值前 n 位，或者后 n 位的时间序列。

获取 HTTP 请求数前 5 位的时序样本数据，可以使用表达式：

```
topk(5, http_requests_total)
```

`quantile` 用于计算当前样本数据值的分布情况 quantile(φ, express) ，其中 `0 ≤ φ ≤ 1`。

例如，当 φ 为 0.5 时，即表示找到当前样本数据中的中位数：

```
quantile(0.5, http_requests_total)
```

返回结果如下：

```
{}   656
```

## 二元运算符优先级

在 Prometheus 系统中，二元运算符优先级从高到低的顺序为：

1. `^`
2. `*`, `/`, `%`
3. `+`, `-`
4. `==`, `!=`, `<=`, `<`, `>=`, `>`
5. `and`, `unless`
6. `or`

具有相同优先级的运算符是满足结合律的（左结合）。例如，`2 * 3 % 2` 等价于 `(2 * 3) % 2`。运算符 `^` 例外，`^` 满足的是右结合，例如，`2 ^ 3 ^ 2` 等价于 `2 ^ (3 ^ 2)`。



# 内置函数

Prometheus 提供了其它大量的内置函数，可以对时序数据进行丰富的处理。某些函数有默认的参数，例如：`year(v=vector(time()) instant-vector)`。其中参数 `v` 是一个瞬时向量，如果不提供该参数，将使用默认值 `vector(time())`。instant-vector 表示参数类型。

## abs()

`abs(v instant-vector)` 返回输入向量的所有样本的绝对值。

## absent()

`absent(v instant-vector)`，如果传递给它的向量参数具有样本数据，则返回空向量；如果传递的向量参数没有样本数据，则返回不带度量指标名称且带有标签的时间序列，且样本值为1。

当监控度量指标时，如果获取到的样本数据是空的， 使用 absent 方法对告警是非常有用的。例如：

```
# 这里提供的向量有样本数据
absent(http_requests_total{method="get"})  => no data
absent(sum(http_requests_total{method="get"}))  => no data

# 由于不存在度量指标 nonexistent，所以 返回不带度量指标名称且带有标签的时间序列，且样本值为1
absent(nonexistent{job="myjob"})  => {job="myjob"}  1
# 正则匹配的 instance 不作为返回 labels 中的一部分
absent(nonexistent{job="myjob",instance=~".*"})  => {job="myjob"}  1

# sum 函数返回的时间序列不带有标签，且没有样本数据
absent(sum(nonexistent{job="myjob"}))  => {}  1
```

## ceil()

`ceil(v instant-vector)` 将 v 中所有元素的样本值向上四舍五入到最接近的整数。例如：

```
node_load5{instance="192.168.1.75:9100"} # 结果为 2.79
ceil(node_load5{instance="192.168.1.75:9100"}) # 结果为 3
```

## changes()

`changes(v range-vector)` 输入一个区间向量， 返回这个区间向量内每个样本数据值变化的次数（瞬时向量）。例如：

```
# 如果样本数据值没有发生变化，则返回结果为 1
changes(node_load5{instance="192.168.1.75:9100"}[1m]) # 结果为 1
```

## clamp_max()

`clamp_max(v instant-vector, max scalar)` 函数，输入一个瞬时向量和最大值，样本数据值若大于 max，则改为 max，否则不变。例如：

```
node_load5{instance="192.168.1.75:9100"} # 结果为 2.79
clamp_max(node_load5{instance="192.168.1.75:9100"}, 2) # 结果为 2
```

## clamp_min()

`clamp_min(v instant-vector, min scalar)` 函数，输入一个瞬时向量和最小值，样本数据值若小于 min，则改为 min，否则不变。例如：

```
node_load5{instance="192.168.1.75:9100"} # 结果为 2.79
clamp_min(node_load5{instance="192.168.1.75:9100"}, 3) # 结果为 3
```

## day_of_month()

`day_of_month(v=vector(time()) instant-vector)` 函数，返回被给定 UTC 时间所在月的第几天。返回值范围：1~31。

## day_of_week()

`day_of_week(v=vector(time()) instant-vector)` 函数，返回被给定 UTC 时间所在周的第几天。返回值范围：0~6，0 表示星期天。

## days_in_month()

`days_in_month(v=vector(time()) instant-vector)` 函数，返回当月一共有多少天。返回值范围：28~31。

## delta()

`delta(v range-vector)` 的参数是一个区间向量，返回一个瞬时向量。它计算一个区间向量 v 的第一个元素和最后一个元素之间的差值。由于这个值被外推到指定的整个时间范围，所以即使样本值都是整数，你仍然可能会得到一个非整数值。

例如，下面的例子返回过去两小时的 CPU 温度差：

```
delta(cpu_temp_celsius{host="zeus"}[2h])
```

这个函数一般只用在 Gauge 类型的时间序列上。

## deriv()

`deriv(v range-vector)` 的参数是一个区间向量,返回一个瞬时向量。它使用简单的线性回归计算区间向量 v 中各个时间序列的导数。

这个函数一般只用在 Gauge 类型的时间序列上。

## exp()

`exp(v instant-vector)` 函数，输入一个瞬时向量，返回各个样本值的 `e` 的指数值，即 e 的 N 次方。当 N 的值足够大时会返回 `+Inf`。特殊情况为：

- `Exp(+Inf) = +Inf`
- `Exp(NaN) = NaN`

## floor()

`floor(v instant-vector)` 函数与 ceil() 函数相反，将 v 中所有元素的样本值向下四舍五入到最接近的整数。

## histogram_quantile()

`histogram_quantile(φ float, b instant-vector)` 从 bucket 类型的向量 `b` 中计算 φ (0 ≤ φ ≤ 1) 分位数（百分位数的一般形式）的样本的最大值。（有关 φ 分位数的详细说明以及直方图指标类型的使用，请参阅[直方图和摘要](https://prometheus.io/docs/practices/histograms)）。向量 `b` 中的样本是每个 bucket 的采样点数量。每个样本的 labels 中必须要有 `le` 这个 label 来表示每个 bucket 的上边界，没有 `le` 标签的样本会被忽略。直方图指标类型自动提供带有 `_bucket` 后缀和相应标签的时间序列。

可以使用 `rate()` 函数来指定分位数计算的时间窗口。

例如，一个直方图指标名称为 `employee_age_bucket_bucket`，要计算过去 10 分钟内 第 90 个百分位数，请使用以下表达式：

```
histogram_quantile(0.9, rate(employee_age_bucket_bucket[10m]))
```

返回：













# 陷阱

## 失效

执行查询操作时，独立于当前时刻被选中的时间序列数据所对应的时间戳，这个时间戳主要用来进行聚合操作，包括 `sum`, `avg` 等，大多数聚合的时间序列数据所对应的时间戳没有对齐。由于它们的独立性，我们需要在这些时间戳中选择一个时间戳，并已这个时间戳为基准，获取小于且最接近这个时间戳的时间序列数据。

如果采样目标或告警规则不再返回之前存在的时间序列的样本，则该时间序列将被标记为失效。如果删除了采样目标，则之前返回的时间序列也会很快被标记为失效。

如果在某个时间序列被标记为失效后在该时间戳处执行查询操作，则不会为该时间序列返回任何值。如果随后在该时间序列中插入了新的样本，则照常返回时间序列数据。

如果在采样时间戳前 5 分钟（默认情况）未找到任何样本，则该时间戳不会返回任何任何该时间序列的值。这实际上意味着你在图表中看到的数据都是在当前时刻 5 分钟前的数据。

对于在采样点中包含时间戳的时间序列，不会被标记为失效。在这种情况下，仅使用 5 分钟阈值检测的规则。

## 避免慢查询和高负载

如果一个查询需要操作非常大的数据量，图表绘制很可能会超时，或者服务器负载过高。因此，在对未知数据构建查询时，始终需要在 Prometheus 表达式浏览器的表格视图中构建查询，直到结果是看起来合理的（最多为数百个，而不是数千个）。只有当你已经充分过滤或者聚合数据时，才切换到图表模式。如果表达式的查询结果仍然需要很长时间才能绘制出来，则需要通过记录规则重新清洗数据。

像 `api_http_requests_total` 这样简单的度量指标名称选择器，可以扩展到具有不同标签的数千个时间序列中，这对于 Prometheus 的查询语言是非常重要的。还要记住，对于聚合操作来说，即使输出的时间序列集非常少，它也会在服务器上产生负载。这类似于在关系型数据库中查询一个字段的总和，总是非常缓慢。
