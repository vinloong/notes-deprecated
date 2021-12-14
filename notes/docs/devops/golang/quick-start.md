



## 国际惯例



vi hello.go

```go
package main

import "fmt"

func main() {
    fmt.Println("hello, world!")
}
```

执行 `go run hello.go`,命令

```shell
$ go run hello.go 
hello, world!
```



`GOROOT`：go 的安装目录

`GOPATH` ：自定义的工作空间

`GOBIN`：go 程序生成的可执行程序的目录





`go build`

`go get`

`go env`



go 包管理工具



go mod 



# 数组和切片

## 数组

```go
var a [3]int                    // 定义长度为3的int型数组, 元素全部为0
var b = [...]int{1, 2, 3}       // 定义长度为3的int型数组, 元素为 1, 2, 3
var c = [...]int{2: 3, 1: 2}    // 定义长度为3的int型数组, 元素为 0, 2, 3
var d = [...]int{1, 2, 4: 5, 6} // 定义长度为6的int型数组, 元素为 1, 2, 0, 0, 5, 6
```



## 切片

```go
var(
    a []int               // nil切片, 和 nil 相等, 一般用来表示一个不存在的切片
    b = []int{}           // 空切片, 和 nil 不相等, 一般用来表示一个空的集合
    c = []int{1, 2, 3}    // 有3个元素的切片, len和cap都为3
    d = c[:2]             // 有2个元素的切片, len为2, cap为3
    e = c[0:2:cap(c)]     // 有2个元素的切片, len为2, cap为3
    f = c[:0]             // 有0个元素的切片, len为0, cap为3
    g = make([]int, 3)    // 有3个元素的切片, len和cap都为3
    h = make([]int, 2, 3) // 有2个元素的切片, len为2, cap为3
    i = make([]int, 0, 3) // 有0个元素的切片, len为0, cap为3
)   

// 尾部追加N个元素
append(a,1)				   // 追加1个元素
append(a,1,2,3)			   // 追加多个元素, 手写解包方式
append(a,[]int{1,2,3}...)  // 追加一个切片, 切片需要解包

// 开头添加元素
a = append([]int{0}, a...)        // 在开头添加1个元素
a = append([]int{-3,-2,-1}, a...) // 在开头添加1个切片

// 链式操作
a = append(a[:i], append([]int{x}, a[i:]...)...)     // 在第i个位置插入x
a = append(a[:i], append([]int{1,2,3}, a[i:]...)...) // 在第i个位置插入切片

a = a[:len(a)-1]   // 删除尾部1个元素
a = a[:len(a)-N]   // 删除尾部N个元素

a = a[1:] // 删除开头1个元素
a = a[N:] // 删除开头N个元素
```





- `len`为`0`但是`cap`容量不为`0`的切片则是非常有用的特性
- 一般很少将切片和`nil`值做直接的比较
- 在判断一个切片是否为空时，一般通过`len`获取切片的长度来判断
- `len`和`cap`都为`0`的话，则变成一个真正的空切片，虽然它并不是一个`nil`值的切片

避免切片内存泄露

