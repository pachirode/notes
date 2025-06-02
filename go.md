# GO

### 平台

两个版本的编译器

- `gc`
    - 原生，已经一直到 `win`
    - 使用 `C` 的工具链
    - 编译之后的代码无法使用 `gcc` 链接
- `gccgo`
    - 使用 `gcc`，编译速度稍慢，运行稍快
    - 提供一些与 `C` 之间的互操作

### `runtime`

`Go` 编译器产生的是本地可执行代码，这些代码仍旧运行在 `Go` 的 `runtime`，它类似于其他语言使用的虚拟机，负责内存分配、垃圾回收等
是每个 `Go` 包最顶层的包，打包时会把它嵌入到了每一个可执行文件当中使得打包体积增大，但是它不依赖其他文件

### Linux 上安装环境

```bash
yum install -y wget
wget https://dl.google.com/go/go1.24.0.linux-amd64.tar.gz
tar -zxvf go1.24.0.linux-amd64.tar.gz
vim .bashrc
    export GOROOT=/root/go
    export GOPATH=/root/projects/go
    export PATH=$PATH:$GOROOT/bin:$GPPATH/bin
source ~/.bashrc
go env -w GOPROXY=https://goproxy.io,direct
go env -w GO111MODULE=on
```

### 配置

```bash
go env -w GOPROXY=https://goproxy.io,direct
```

### 常用工具

- `godoc` 工具会从 `Go` 程序和包文件中提取顶级声明的首行注释和每个对象的相关注释，并生成相关文档
    - 只能获取 `Go` 安装目录下的注释内容，可以作为一个 `web` 服务器 `godoc -http=:6060`
    - 命令
        - `go doc package`
        - `go doc package/subpackage`
        - `go doc package function`
- `go install`
- `go fix`
    - 使得代码从低版本迁移到高版本，复杂的逻辑会给出提示
- `go test`

### 简单语法

```go
package main // 包声明, `pange main` 表明是一个独立执行的程序

import "fmt" // 引入包

func main() {
	fmt.Println("Hello world")
}

```

> `go run hello.go` 运行程序
> `go build hello.go` 生成二进制文件

- 标记    
  -`GO` 程序是多个标记组成的，关键字，标识符，常量，字符串，符号
- 行分隔符
- 注释
- 标识符
    - 第一个字符必须是字母或者下划线，避免使用关键字
- 字符串连接(`+`)
- 关键字
    - `break`    `default`    `func`    `interface`    `select`
    - `case`    `defer	go`    `map`    `struct`
    - `chan`    `else`    `goto`    `package`    `switch`
    - `const`    `fallthrough`    `if`    `range`    `type`
    - `ontinue`    `for`    `import`    `return`    `var`
- 预定义标识符
    - `append`    `bool`    `byte`    `cap`    `close`    `complex`    `complex64`    `complex128`    `uint16`
    - `copy`    `false`    `float32`    `float64`    `imag`    `int`    `int8`    `int16`    `uint32`
    - `int32`    `int64`    `iota`    `len`    `make`    `new`    `nil`    `panic`    `uint64`
    - `print`    `println`    `real`    `recover`    `string`    `true`    `uint`    `uint8`    `uintptr`
- 空格
- 格式化字符串
    - `Sprintf`
    - `Printf`
- 变量
  ```go
    var v_name = value // 可以根据值自行判断变量类型
    v_name := value // 如果变量已经使用 `var` 声明过了，再使用 `:=` 声明，就会产生编译错误(如果是多个变量同时声明，需要保证至少一个是新变量)
  
    // 多变量同时声明
    var name1, name2, name3 type
    var name1, name2, name3 = v1, v2, v3
    var (
    name string
    age int
    )
  ```
- 值类型和引用类型
    - 值类型直接保存数据，赋值操作实际上是复制了这些值
    - 引用类型保存的是数据的地址，复制实际上复制了地址，最终指向同一个内存空间
- `:=` 赋值
    - 只能用在函数体内，不可以声明全局变量
  > 局部变量赋值必须使用；全局变量允许声明但是不使用
- 常量
    - 程序运行过程中不会被修改的量。
    - 常量可以作为枚举，常量组
    - 常量组中如果不指定类型和初始化值，则与上一行非空常量右值相同

```go
package main

const (
	x uint16 = 16
	y
	s = "abc"
	z
)

func main() {
	const LENGTH int = 10
}

```

- `iota`
    - 特殊常量，一个可以被编译器修改的常量
    - 通常用于创建一组相关的常量
    - 如果中断 `iota` 自增必须显示恢复，且后续自增值按照行序自增
    - 常量不会分配存储空间，因此无法像变量一样通过内存取址来取值
    - 每次 `const` 出现都会让 `iota` 初始化为 0

```go
package main

func main() {
	const (
		a = iota //0
		b        //1
		c        //2
	)

	const (
		_  = iota             // 忽略第一个值
		KB = 1 << (10 * iota) // 1024
		MB                    // 1048576
		GB                    // 1073741824
	)
}

```

##### 运算符

- 运算符
    - 算术运算符
    - 关系运算符
    - 逻辑运算符
    - 位运算符
    - 赋值运算符
    - 其他运算符
        - `&` 返回变量存储地址
        - `*` 指针变量
- 输入输出格式化
    - `%v`
        - 缺省格式
    - `%#v`
        - `go` 语法打印
    - `%T`
        - 类型打印
    - `%c`
        - 字符
    - `%q`
        - 有引号的字符
    - `%U`
        - `Unicode`
    - `%#U`
    - `%e`
        - 科学技术
    - `%f`
        - 十进制小数
    - `%s`
        - 字符串
- 结构体
    - 结构体之间可以相互赋值，是浅拷贝，拷贝的是指针地址
    - 内嵌结构体不提供名称，直接继承其内部所有的字段和方法
    - 如果内嵌结构体和外部结构体字段系统，先要使用内嵌结构体需要外部调用申明内嵌结构体
    - 结构体标签
        - 附属于字段的字符串，辅助序列化
    - 结构体方法
        - 首字母大写公开方法
        - 首字母小写内部方法，只有同包可以使用
    - 结构体指针方法
        - 值传递涉及到拷贝，无法实际影响外部存储的数据

```go
type struct_variable_type struct {
member definition
}

var_name := struct_variable_type{value1, value2, ...}

type Book struct {
title string
author string
subject string
book_id int
}

func main() {
Book{
title: "Go"
author: "XYZ"
subject: "Go Programming"
book_id: 6495407,
}
Book{"Go Programming", "XYZ", "Go Programming Tutorial", 6495407}

var c Book = Book{} // 零值结构体会占用内存，只不过里面的每个字段都是零值
var c Book
var c  *Book = new(Book) // 返回的是指针类型，这个零值只会占用一个指针

type Teacher struct {
name string
age int
title string
}


type Course struct {
Teacher // 内嵌结构体不提供名称，直接继承其内部所有的字段和方法；如果内嵌结构体和外部结构体字段系统，先要使用内嵌结构体需要外部调用申明内嵌结构体
price int
name string
url string
}

type Info struct {
Name string
Age  int `json:"age,omitempty"`
Sex  string
}

func (i Info) GetInfo() float64 {
return ""
}

func (i Info) expand() {
i.Age *= 2
}

}
```

- 并发
    - 使用 `goroutines` 和 `channels` 来实现
        - `goroutines`
            - 并发执行单位，类似线程
            - 用户无需手动创建
            - `go` 关键字启动
            - 非阻塞的，同时可以有大量的运行
          > 同一程序中的所有 `goroutine` 共享同一内存地址
          ```go
            go func(param_list)
          ```
        - `channel`
            - 用于再 `goroutines` 中通讯
            - 支持同步和数据共享，避免显式的锁机制
            - `chan` 关键字创建，`<-` 操作符发送和接收数据
          ```go
            ch <- v // 把 v 发送给通道 ch
            v := <- ch // 从 cha 接收数据，并把值赋值给 v
    
          ```
        - 通道缓冲区
          ```go
            ch := make(chan int, 100) // 第二个参数为指定缓冲区大小
          ```
            - 带缓冲区的通道允许发送和接收数据处于异步状态。如果缓冲区已满，发送操作将阻塞，直到有空间。
        - `select`
          ```go
            func test (c, quit chan int) {
                x, y := 0, 1
                for {
                select {
                    case c <- x:
                        x, y = y, x+y
                    case <-quit:
                        fmt.Println("quit")
                        return
                }
            }
          }
          ```
        - `waitgroup`
            - 用于等待多个`goroutines`执行完成
          ```go
            func worker(id int, wg *sync.WaitGroup) {
                defer wg.Done()
                fmt.Println("Worker", id)
            }
            func main() {
                var  wg sync.WaitGroup
          
                for i := 1; i <= 3; i++ {
                    wg.Add(1)
                    go worker(i, &wg)
                }
          
                wg.Wait()
            }
          ```
        - `context` 控制生命周期
            - `context.withCancel`
            - `context.withTimeout`
        - `Mutex` 互斥锁，保护共享资源
        - `Scheduler`
            - `Go` 基于 `GMP` 模型，调度器将 `goroutines` 分配到系统线程中执行，通过 `M`, `P` 配合高效管理并发
            - `Goroutines`
            - `Machine` 系统线程
            - `Processor` 逻辑处理器

### 模块

模块下不能有多个 `main`, 会认为是函数重复，可以将他们放到不同的文件夹下面解决这个问题

##### 包

包是结构化代码的一种方式

- 编译
    - 如果编译的包名不是 `main` 包，编译之后产生的对象将会是 `.a` 结尾的文件，不是可执行文件
    - 构建一个程序，则包和包内的文件必须以正确的顺序进行编译，包的依赖关系决定其构建顺序；属于同一个包的源文件必须被同时编译
    - 如果对一个包进行更改，所有依赖这个包的都需要重新编译
- 显式依赖
    - 使用这个达到快速编译的目的，编译器会从后缀名为 `.o` 的对象文件中提取传递依赖类型的信息
    - `A` 依赖于 `B` ,  `B` 依赖于 `C`
        - 先编译 `C`，然后编译 `B`，最后编译 `A`
        - 为了编译 `A`，编译器读取 `B`
- 别名
    - `import fm "fmt"`
- 作用范围
    - 导入包之后，这些对象在本包的作用域内都是全局的
    - 可见性当标识符以一个大写字母开头就可以被外部包的代码使用，如果小写字母开头对外部不可见

##### 标准库

自带的可以直接使用的包

- `Win`
    - `pkg\windows_386`
- `Linux`
    - `pkg\linux_amd64`

### 函数

- `main()` 函数
    - 一个可执行程序必须包含的，没有的话会引发构建错误
    - 如果有 `init()` 先执行
        - 主要用来初始化变量
        - 当一个程序开始之前调用后台执行的 `goroutine`
    - 没有参数也没有返回值，添加构建失败
- 用法规范
    - 只有当某个函数需要被外部包调用的时候才使用大写字母开头

- 调试
    - 调试代码阶段可以使用一些预定义的方法，如 `println()`

> 编译器会自动添加分号作为语句的结束

```go
func functionName(parameters) (returnParameters) {}
```

##### 多返回值函数

函数经常使用两个返回值来表示执行是否成功，第二个值可以是布尔值或者错误类型

- 成功
    - 返回某个值和 `true`
- 失败
    - 返回零值和 `false`

```go
anInt, _ = strconv.Atoi(origStr) // 发生错误时候直接忽略错误

// 处理错误
an, err := strconv.Atoi(orig)
if err != nil {
fmt.Printf("orig %s is not an integer - exiting with error\n", orig)
return
}

```

##### 按照值传递和按照引用传递

默认使用按值传递来传递参数，就是传递参数的副本，不会影响原来的值
如果想要在函数内部修改外面的变量，需要将地址传递给函数，这就是按引用传递

##### 命名返回值

命名返回值作为结果形参被初始化为相应类型的零值，当需要返回的时候，我们只需要一条简单的不带参数的 `return`

```go
func getX2AndX3(input int) (int, int) {
return 2 * input, 3 * input
}

func getX2AndX3_2(input int) (x2 int, x3 int) {
x2 = 2 * input
x3 = 3 * input
return
}
```

##### 变长参数

函数的最后一个参数使用 `...type` 的形式，这个函数就可以处理一个变长参数。这个参数类型与切片

```go
func myFunc(a, b, arg ...int) {}
```

##### 内置函数

- `close()`
    - 管道通信
- `len()` `cap()`
- `new()` `make()`
    - 用于分配内存
- `copy()` `append()`

##### 推迟和追踪

`defer` 允许我们推迟到函数返回之前才执行某些语句，用法类似于 `finally`，一般用于释放一些分配的资源

- 多个 `defer` 被注册时，它们会以逆序执行
- 实现代码追踪
- 记录日志

```go
defer file.Close()

mu.Lock()
defer mu.Unlock()

func doDB() {
connectToDB()
defer disconnectFromDB() // 用来关闭资源连接
doSomething()
doSomethingElse()
doYetAnotherThing()
return
}

func trace(s string) { fmt.Println("entering:", s) }
func untrace(s string) { fmt.Println("leaving:", s) }
func a() {
trace("a")
defer untrace("a")
fmt.Println("in a")
}

```

##### 函数作为参数

函数可以作为其他函数的参数进行传递，在其他函数内部调用，叫做回调

```go
package main

import (
	"fmt"
)

func main() {
	callback(1, Add)
}

func Add(a, b int) {
	fmt.Printf("The sum of %d and %d is: %d\n", a, b, a+b)
}

func callback(y int, f func(int, int)) {
	f(y, 2) // this becomes Add(1, 2)
}

```

##### 闭包

不希望给函数起名字可以使用匿名函数，这样的函数无法独立存在，可以被赋值给某个变量，再通过函数名对函数进行调用
使得一些函数捕获到一些外部的状态

- 将函数作为返回值
- 调试
    - `runtime`
        - `Caller`
            - 需要的地方实现一个 `where` 的闭包函数打印函数执行

```go
func() {
sum := 0
for i := 1; i <= 1e6; i++ {
sum += i
}
}()

// 工厂函数
func MakeAddSuffix(suffix string) func(string) string {
return func (name string) string {
if !strings.HasSuffix(name, suffix) {
return name + suffix
}
return name
}
}

var where = log.Print
func func1() {
where()
... some code
where()
... some code
where()
}
```

### 注释

注释不会编译，但是可以使用 `godoc`，只要进行首行注释即可

### 类型

- 使用 `type` 可以定义自己想要的类型，可以是不存在的也可以是一个已经存在的类型的别名
- 这不是真正意义上的别名，使用这种方式定义类型可以有更多特性且类型转换必须使用显式的转换
    - 新类型不会拥有原类型所附带的方法

> `Go` 语言不存在隐式类型转换

```go
type IZ int
var a IZ = 5

b := int(a)
```

### 常量

常量的值必须是在编译的时候就能确定的，编译期间自定义函数无法使用，内置函数可以使用

- 作用域
    - 变量在函数体外则被认为是全局变量
    - 可以在内层代码块里面使用同名的变量，外部变量会暂时隐藏
- 编译
    - 变量可以在编译期间就赋值

### 基本数据类型

- 数据类型
    - `bool`
    - 数值
        - `int8/16/32/64`
        - `uint8/16/32/64`
        - `float32/64`
        - `complex64/128`
        - `byte`
            - 没有专门的字符类型，如果要存储当个字符，一般使用 `byte` 来保存
            - 字符串是由字节组成
            - 使用 `'`
            - `uint8`
        - `rune`
            - 和字符处理相关
            - `uint32`
        - `uint`
        - `int`
            - 动态类型，取决于机器本身是多少位
        - `uintptr`
    - 字符串类型
    - 派生类
        - `Pointer`
        - 数组
        - 结构化
        - `Channel`
        - 函数
        - 切片
        - 接口
        - `Map`

##### 布尔

两个类型相同的值才可以进行比较，如果类型为接口也必须保证实现相同的接口

##### 字符串

`UTF-8` 字符的一个序列（`ASCII` 为一个字节其他为二到四），因此字符串需要占用 1-4 字节，所以它不需要对 `UTF-8` 字符集进行解码
字符串是一种值类型且值不可改，本质上是定长数组

- 字面值
    - 解释字符串
        - 使用双引号括起来，包含转义字符
    - 非解释字符串
        - 使用反引号括起来

> 获取字符串中某个字节的地址的行为是非法的，例如：`&str[i]`

预定义处理函数

- `strings` 包
    - `TrimSpace(s)`
        - 剔除字符串开头和结尾的空白符号
    - `Join(sl []string, sep string)`
        - 使用分割符号来拼接组成一个字符串
- `strconv` 包
    - 与字符串相关的类型转换

##### 指针

取地址符 `&`，放到一个变量前使用就会返回相应变量的内存地址，存储这个地址的数据类型叫做指针
类型更改器 `*`，放在指针类型前，获取指针所指向的内容
反引用 `*`，放在一个指针前，获取指针指向地址上所存储的值

> 不能获取字面量或常量的地址

### 控制结构

- 条件语句和循环语句
    - `if else`
    - `for`
    - `goto`
        - 无条件的转移到过程中指定的行，会导致程序流程混乱，一般不使用
        - 跳出多层循环
        - 集中处理错误
    - `swith`
        - 基于不同条件执行不同动作
    - `select`
        - 只能用于通道操作，每个 `case` 必须是通道
        - 如果多个通道都准备好了，会随机选择一个通道执行

##### `if-else`

```go
if condition1 {
// do something	
} else if condition2 {
// do something else	
} else {
// catch-all or default
}

```

##### `switch`

```go
switch i {
case 0: fallthrough
case 1:
f() // 当 i == 0 时函数也会被调用
}
```

### 集合

包含大量条目的数据结构

##### 数组

具有相同唯一类型已编号且长度固定的数据序列
数组元素可以通过索引来访问
可以使用多维数组，但是多维数组传递会消耗大量内存，有两种方式可以避免这个问题

- 传递数组的指针
    - 不常用
- 使用数组切片

> 如果想要让数组支持为任意类型可以使用空接口作为类型，在使用值的时候需要先判断类型

```go
var identifier [len]type
var arrAge = [5]int{18, 20, 15, 22, 16}
var arrLazy = [...]int{5, 6, 7, 8, 22} // 实际上变为切片
var arrKeyValue = [5]string{3: "Chris", 4: "Ron"}
```

##### 切片

对数组连续片段的引用（通常为匿名数组），切片可以索引
多个切片如果表示同一个数组的片段，它们可以共享数据

- 使用 `make` 可以创建一个切片
- `byte` 切片
    - `Buffer`
        - 读写长度未知的 `bytes`
- 切片重组
    - 切片改变长度的过程，切片达到容量上限之后可以扩容
    - `slice1 = slice1[0:end]`
- `copy` 复制
- `append` 追加
- 垃圾回收
    - 少量数据占用大量内存，可以通过拷贝需要的部分到新的切片中

> `new` 适用于值类型；`make` 只适合三种内建引用类型：`slice` `map` `channel`

```go
var identifier []type
var slice1 []type = arr1[start:end]
slice1 := make([]type, len)
```

##### `map`

- `key` 是可比较的，数组切片结构体(含有数组切片的)不能作为 `key`
- `map` 切片
    - 使用两次 `make`

> 不能使用 `new` 创建 `map`，否则会获得一个空引用的指针

```go
var map1 map[keytype]valuetype
```

##### `for-range`

```go
// 数组切片
for ix, value := range slice1 {
...
}
// map
for key, value := range map1 {
...
}

```

### 结构体

`*` 选择器用来引用结构体字段

- 混合字面量
    - 值的顺序必须按照字段顺序来写
- 结构体中所有的数据都是存储在连续的内存中的
- 结构体工厂
    - 不支持面向对象中的构造函数，可以使用工程方法实现
    - 强制使用
        - 使用可见性原则，结构体开头字母小写
- 标签
    - 结构体中的字段除了有名字和类型外，还可以有一个可选的标签
- 匿名字段
    - 字段没有显式的名字，只有字段类型是必须的
    - 匿名字段可以是结构体类型
- 内嵌结构体
    - 可以实现类似继承的功能
    - 外层名字会覆盖内层名字
    - 如果相同的名字在同一级别出现了两次，如果这个名字被程序使用了，将会引发一个错误（不使用没关系）
- 方法（特殊函数）
    - 作用在接收者上的一个函数，接收者是某种类型的变量
        - 结构体，函数或者 `int` 等基本类型的别名，但是不可以是接口和指针类型（其他允许类型的指针可以）
        - 鉴于性能的原因，接收者最常使用指针
        - 别名类型没有原始类型上已经定义的方法
    - 类型代码和绑定上面的方法可以不在一个文件中，但是必须要在一个包里面
        - 如果不在一个包里面，可以先使用别名
    - 不允许重载，一个类型只能有一个给定名称的方法，如果基于接收者类型可以重载
- 嵌入功能
    - 聚合
        - 包含一个所需功能类型的具体体字段
        - 消耗指针
    - 内嵌
        - 导入功能类型
- `String()` 方法和格式化描述符
    - 会被用在 `fmt.Printf()` 中生成默认输出，等同于格式化字符串 `%v` 产生的输出

```go
type identifier struct {
field1 type1
field2 type2
...
}
var t *indentifier
t = new(T) // 返回指向结构体类型变量的指针
ms := &struct1{10, 15.5, "Chris"} // 此时 ms 的类型是 *struct1，底层调用 new()

// 结构体方法
type File struct {
fd      int    // 文件描述符
name    string // 文件名
}

func NewFile(fd int, name string) *File {
if fd < 0 {
return nil
}

return &File{fd, name}
}

// 方法
func (a *denseMatrix) Add(b Matrix) Matrix
func (a *sparseMatrix) Add(b Matrix) Matrix

// 非结构体类型的方法
type IntVector []int

func (v IntVector) Sum() (s int) {
for _, x := range v {
s += x
}
return
}

```

### 垃圾回收

不再使用的变量和结构，会被 `Go` 运行中的一个单独的进程（`GC`） 回收

- `runtime.GC()` 显示调用，只有当内存资源不足时才会使用
- `SetFinalizer`
    - 需要在一个对象被从内存移除前执行一些特殊操作

```go
runtime.SetFinalizer(obj, func (obj *typeObj))
```

### 接口和反射

##### 接口

定义一组方法的集合不包含代码实现，接口里面包含变量

- 只包含一个方法的接口一般使用方法名加 `er` 后缀组成
- 不常用的接口以 `able` 结尾
- 接口可以有值
    - 接口类型的变量
    - 接口值
- 接口可以嵌套
- 即使接口在类型之后才定义，二者处于不同的包中，被单独编译：只要类型实现了接口中的方法，它就实现了此接口
- 类型断言
    - 一个接口包含任意类型的值，使用这种方式来检测它的动态类型
- 类型判断
- 空接口
    - 空接口或者最小接口不包含任何方法，可以赋任何类型的值
    - 可以构建通用类型的数组
- 接口到接口
    - 一个接口的值可以赋值给另一个接口变量。只要底层类型实现必要方法
- 动态类型
    - 意味着对象可以根据提供的方法被处理，而忽略掉它们的实际类型
    - 其他语言中的动态类型是延迟绑定的，方法只是用参数和变量简单的调用，只要在运行时才解析；`Go` 需要编译器静态检查支持

```go
if v, ok := varI.(T); ok {  // 断言
Process(v)
return
}

switch t := areaIntf.(type) { // 类型判断
case *Square:
fmt.Printf("Type Square %T with value %v\n", t, t)
case *Circle:
fmt.Printf("Type Circle %T with value %v\n", t, t)
}

if sv, ok := v.(Stringer); ok { // 测试是否实现接口
fmt.Printf("v implements String(): %s\n", sv.String())
}

// 多态
type Shaper interface {
Area() float32
}

type Square struct {
side float32
}

func (sq *Square) Area() float32 {
return sq.side * sq.side
}

func main() {
sq1 := new(Square)
sq1.side = 5

var areaIntf Shaper
areaIntf = sq1
fmt.Printf("The square has area: %f\n", areaIntf.Area())
}
```

##### 反射

用于程序检查其所拥有的结构，尤其是类型。可以在运行是检测类型和变量，对于没有源码的包很有用

- `reflect.TypeOf()` `reflect.ValueOf()`
- 返回被检查对象的类型和值
- 通过检查一个接口的值，变量首先被转换成空接口
- `Kind` 返回底层数据类型
    - 即使使用 `type` 取别名，最后返回的也是底层类型
- 通过反射修改值
    - 是否可以设置是 `value` 的一个属性，可以使用 `CanSet()` 来判断这个反射是否可以设置
- 反射结构
    - `NumField()` 方法返回结构内的字段数量；通过一个 `for` 循环用索引取得每个字段的值 `Field(i)`

```go
var x float64 = 3.4
v := reflect.ValueOf(x)
fmt.Println("settability of v:", v.CanSet())
v = reflect.ValueOf(&x)
v = v.Elem()
v.SetFloat(3.1415)

func Printf(format string, args ... interface{}) (n int, err error)
... // 参数为空接口类型
```

##### 动态类型

`Go` 结合了接口值，静态类型检查（是否该类型实现接口）
接收一个或者多个接口类型作为参数的函数，其实参可以实现该接口的类型变量；实现了某个接口类型的可以被传递给任何以此参数为接口的函数

```go
type IDuck interface {
Quack()
Walk()
}

func DuckDance(duck IDuck) {
for i := 1; i <= 3; i++ {
duck.Quack()
duck.Walk()
}
}

type Bird struct {
// ...
}

func (b *Bird) Quack() {
fmt.Println("I am quacking!")
}

func (b *Bird) Walk()  {
fmt.Println("I am walking!")
}

func main() {
b := new(Bird)
DuckDance(b)
}

```

### 结构体、集合、高阶函数

##### 高阶函数

把函数作为定义所需要方法

```go
func (cs Cars) Process(f func (car *Car)) {
for _, c := range cs {
f(c)
}
}

```

### 错误处理和测试

`defer-panic-and-recover`
从底层向更高层抛异常太浪费资源，此处的异常是作为处理错误最后的手段
`panic` `recover` 是用来处理真正的异常而不是普通的报错

##### 错误处理

`Go` 中有预先定义的 `error` 接口类型

- 任何时候当想要一个新的错误类型，都可以使用 `errors` 包
- 自定义错误
    - 可以包含除了低级错误之外的其他信息
- 命名规范
    - 类型
        - 错误类型以 `...Error` 结尾
    - 变量
        - 以 `err...` 或 `Err...` 开头或者直接叫 `err`
- `syscall`
    - 低阶外部包，用来提供基本调用的原始接口。返回封装整数类型的错误码 `syscall.Errno`
    - 大部分返回一个结果和可能的错误

```go
type error interface {
Error() string
}

var errNotFound error = errors.New("Not found error")

// 自定义错误
type PathError struct {
Op string
Path string
Err error
}

func (e *PathError) Error() string {
return fmt.Sprintf("%s %s: %v", e.Op, e.Path, e.Err)
}

```

##### 运行时异常和 `panic`

当发生像是数组下表越界或者断言失败的运行错误时候会触发 `panic`，伴随程序的崩溃抛出一个 `runtime.Error`
接口类型的值，和普通错误不同，这个错误有 `RuntimeError()`

- `panic` 可以直接从代码初始化
    - 当错误条件很严苛不可恢复，程序不能继续运行时，可以使用 `panic` 函数产生一个中止程序的运行错误
- 接收一个做任意类型的参数，通常是字符串，在程序死亡时打印
- 多层嵌套函数中调用，可以马上终止当前函数，所有 `defer` 都会保证执行
- 不要随意使用

```go
func main() {
fmt.Println("Starting the program")
panic("A severe error occurred: stopping the program!")
fmt.Println("Ending the program")
}

```

##### 从 `panic` 中恢复

用于从 `panic` 或者错误场景中恢复，程序停止终止状态恢复继续运行

- `recover` 只能用在 `defer` 修饰的函数，用于取得 `panic` 中传递过来的错误值。如果正常执行，调用 `recover` 返回 `nil`
  ，不会有任何影响

```go
func protect(g func ()) {
defer func () {
log.Println("done")
if err := recover(); err != nil {
log.Printf("run time panic: %v", err)
}
}()
log.Println("start")
g() //   possible runtime-error
}

```

##### 自定义包中的错误处理和 `panicking`

- 包内部，总是应该从 `panic` 中 `recover`，不允许显式的超出包的范围 `panic`
- 向包的调用者返回错误而不是 `panic`

##### 闭包错误处理模式

这个模式只有当所有的函数都是同一种签名时才能使用

```go
func f(a type1, b type2) //规定相同函数签名

fType1 = func f(a type1, b type2)

func check(err error) { if err != nil { panic(err) } }
func errorHandler(fn fType1) fType1 {
return func (a type1, b type2) {
defer func () {
if err, ok := recover().(error); ok {
log.Printf("run time panic: %v", err)
}
}()
fn(a, b)
}
}
```

### 单元测试和基准测试

`gotest` 是 `Unix bash` 脚本，所以在 `Windows` 需要配置 `MINGW`

##### 单元测试

需要写一些可以频繁执行的小块测试单元来检查代码的正确性，测试程序必须属于被测试的包且文件名必须满足 `*_test.go`

- `_test` 程序不会被普通编译器编译，无法被部署到生产环境。只有 `gotest` 会编译所有程序
- 测试文件必须导入 `testing` 包，并包含一些 `Test` 开头的全局函数
- 测试函数必须有的头部
    - `func TestAbcde(t *testing.T)`
        - `T` 是传递给测试函数的结构体类型，用来管理测试状态，支持格式化测试日志
        - 函数结尾把输出的和想要的结果对比，如果不等于就打印一个错误

```go
func TestAbcde(t *testing.T)
```

### 协程与通道

不要使用全局变量或者共享内存，在并发运算时候会有危险

- 使用 `GOMAXPROCS`
    - 在 `gc` 编译器下需要设置该值大于 `1` 允许运行时支持使用多于一个操作系统线程
    - 所有协程都会共享同一个线程，除非该值设置大于 `1`
    - 会有一个线程池管理许多线程，线程会被分散到多个处理器上，处理器多不一定提升性能

##### 通信

协程之间可以使用共享变量来进行通讯，但是会给所有的共享内存的多线程都带来困难
通道是专门用来负责协程之间的通讯的，从而避开共享内存带来的问题；指定时间内只有一个协程可以对其访问，所以不会发生数据竞争问题


- 通道实际上是先进先出的消息队列
- 引用类型
- `<-` 通信操作符
  - 信息按照箭头方向流动
- 两个携程之间需要通讯，必须给它们同一个通道作为参数
- 默认情况下，通信是同步且无缓冲的
- 无缓冲通道
  - 可以在两端相互阻塞对方，形成死锁
- 使用带缓存的通道
- 信号量模式
  - 协程通过在通道里面放一个值来结束信号
- 关闭通道
  - 可以被显示的关闭
- `select` 切换携程

```go
var ch1 chan string
ch1 = make(chan string)

buf := 100
ch1 := make(chan string, buf) // 带缓冲通道

ch := make(chan float64)
defer close(ch)

select {
case u := <- ch1:
...
case v := <- ch2:
...
...
default: // no value ready to be received
...
}

```