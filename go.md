# GO
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
    ```go
    func main () {
      if a < 20 {}
      if num:= 10; num < 20 {} // 可以将返回值和判断放到一行里面处理，返回值的作用范围被限制在 `if` 块中
  
      for init; condition; post { } 
      for condition { }
      for { }
  
      goto label1
      label1: statement
  
      switch var1 {
        case val1, other:
          ...
        case val2:
          ...
        default:
          ...
      }
    }
    ```
- 函数
- 数组
  - 数组是值类型，赋值会拷贝数组
  - 长度不一样的数组类型不是同一个类型
  - 传递参数的时候不同长度数组无法传参
  - 数组调用的时候是值传递

```go
var arrayName [size]dateType
var numbers [5]int
var numbers [5]int{1, 2, 3, 4, 5}
var numbers [...]int{1, 2, 3, 4, 5} // 数组长度不确定，编译器会自动计算长度

```

- 指针
  - `&` 取地址符号，放在一个变量前面，返回相对应的变量的内存地址
  - 如果指针被定义后没有赋值，默认为 `nil`
```go
var var_name *var -type // 指针声明
var ip *int

package main

import (
"fmt"
)

func main() {
var a int = 20
var ip *int

ip = &a // 在指针变量中存放地址

fmt.Println("变量地址： ", a)
fmt.Println("变量值： ", *ip)
}

```
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
- 切片
  - 切片相当于 动态数组，可以追加元素
  - `len()` 当前长度
  - `cap()` 容量
  - `append()`
    - `go` 不允许调用 `append` 不使用返回值
    - 本质上是往底层数组里面添加元素，但是底层数组的长度是固定的
  - `copy()`
```go
type slice struct {
  array unsafe.Pointer  // 底层数组的地址
  len int // 长度
  cap int // 容量
}

var identifier []type // 声明一个未指定大小的切片
slice := make([]type, len) // 创建切片，capacity 为可选参数
course := [5]int{1, 2, 3, 4, 5}
subCourse := course[1:2] // 通过对数组操作返回

// 切片扩容
number1 := make([]int, len(numbers), cap(numbers) * 2)
copy(number1, numbers)
```
> 切片和数组的区别：1. 数组大小（固定/动态）2.内存（数组定义的时候分配固定的内存，大概率在栈上。切片实际上一个结构体，底层数组可以在堆上）3. 数组传参时候会复制整个数组，切片传递的为引用
> 切片类似 `python` 中的 `list`

- `range`
  - 用于 `for` 循环中迭代数组
  - `map`
  - 字符串
```go
for key, value := range old_map {
    newMap[key] = value
}

// 从通道接收数据直到通道关闭
ch := make(chan int, 2)
ch <- 1
ch <- 2
close(ch)

for i := range ch {
    fmt.Println(i)
}
```
- `Map`
  - 无序键值对集合
  - `key` 类型需要支持 `==` `or` `!=`
  - 获取 `Map` 值时，如果键不存在，返回该类型的零值
  - 引用类型
```go
map_variable := make(map[key_type]value_type, init_capacity)
m := map[string]int{
"apple": 1,
"banana": 2,
"orange": 3,
}
v1 := m["apple"]
v2, ok := m["grape"]

m["apple"] = 5
len := len(m)
delete(m, "apple")
```
> `map` 会自动扩容

- 类型转换
  不支持变量间的隐式类型转换，常量和变量之间支持类型转换
  - 简单的转换 
    - 无法跨大类型转换
  - `strconv`
    - 整数和字符串转换
      - `Itoa`
      - `Atoi`
    - `Parse` 函数
      - `ParseBool`
      - `ParseFloat`
      - `ParseInt`
      - `ParseUint`
    - `Format`
      - 将给定类型的格式化字符串
```go
var a int = 1
var b float = 1.0
a = b // 报错
var a int = 1.0 // 可以

type_name(expression)

var a int = 10
var b float64 = float64(a)

// 字符串转为其他
var a string = "10"
var num int
num, _ = strconv.Atoi(a)
```
- 接口类型转换
  - 类型转换
    - 将一个接口类型转换为另一个接口类型
  - 类型断言
    - 将接口类型转换为指定类型
```go
package main

import "fmt"

type Animal interface {
	Speak() string
}

type Dog struct{}

func (d Dog) Speak() string {
	return "Woof!"
}

type Cat struct{}

func (c Cat) Speak() string {
	return "Meow!"
}

func main() {
	var a Animal

	a = Dog{}
	fmt.Println(a.Speak())
    
    dog, ok := a.(Dog)
    if ok {
        fmt.Println("转换成功：", dog.Speak())
    } else {
        fmt.Println("转换失败")
    }
}

```
- 接口
  - 定义行为的合集，描述了类型必须实现的方法
  - 没有关键字显式的声明某个类型实现了某个接口，只要一个类型实现了接口的全部方法。该方法自动被认为实现了该接口
  - 接口类型变量
    - 动态类型，存储实际值的类型
    - 动态值，存储具体的值
  - 零值接口
    - 未初始化
    - 空接口
      - 可以表示任何类型
  - 用法
    - 多态
    - 解耦
    - 泛化
  - 组合
    - 通过嵌套组合，实现更加复杂的行为描述
  - 动态值
    - 具体类型的值
  - 动态类型
    - 接口变量存储的具体值
  - 错误处理
    - 通过内置的错误接口提供了简单的错误处理机制；错误处理使用显式返回错误方式
    - 当程序运行时，如果遇到空指针或者显式的调用 `panic`，会先触发 `panic` 函数，然后调用延迟函数。继续传递 `panic` ... 如果一路在延迟函数中没有调用 `recover`，则会到达该协程的起点，该协程结束。终止其他协程
    - 错误和异常就是 `error` 和 `panic` 的不同，错误和异常是可以相互转换的
    - 处理方式
      - 没有失败时不使用 `error`
      - `error` 应该放在返回值类型列表的最后一个
      - 错误值统一定义
      - 错误逐级传递，每一层都添加日志
      - 错误处理使用 `defer`
    - `error`接口
      - 标准错误表示
      - `error.Is` 检查是否为特定错误
      - `error.As` 转化为特定类型再处理
      ```go
            type error interface {
            Error() string
        }
      
        func main() {
            err := errors.New("An error occurred")
            fmt.Println(err)
        }
      ```
    - 显式返回值
      - 通过函数的返回值返回错误
      ```go
        func divide(a, b float64) (float64, error) {
            if b == 0 {
                return 0, errors.New("Cannot divide by zero")
            }
            return a / b, nil
        }
        func main() {
            result, err := divide(10, 0)
            if err != nil {
                fmt.Println("Error:", err)
            } else {
                fmt.Println("Result:", result)
            } 
        }
      ```
    - 自定义错误
      - 标准库或者自定义方式创建错误
    - `panic` `recover` `defer`
      - 错误
        - 可能出错的地方出错，可以预料到
      - 异常
        - 不应该出错的地方出错
      - `panic` `recover` 触发和终止异常处理流程
      - `defer` 延迟执行 `defer` 的函数
        - 多条 `defer` 语句执行顺序与声明顺序相反
      - `fmt` 错误格式化
        - `%v` 默认格式
        - `%+v` 如果支持，显示详细的错误信息
        - `%s` 作为字符串输出

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
- 文件处理
  - `os`
    - 常用的
  - `io`
    - 文件，网络等数据源交互
  - `bufio`
    - 通过缓存减少 `IO` 次数，适合频繁读写
  - `path/filepath`
- 类型断言
  - 用于检查接口值实际类型
  ```go
    // interfaceValue 为接口类型变量，typeName 断言类型。如果断言成功 value 就是该接口实际值否则为零值
    value, ok := interfaceValue.(typeName)
    // 另一种断言方式，不返回布尔值，而是在断言失败时引发 `panic`
    value := interfaceValue.(typeName)
  
    switch v := interfaceValue.(type) {
        case  T1:
            // 处理 T1 类型
        case  T2:
            // 处理 T2 类型
        default:
            // 处理其他类型
  }
  ```
- 继承
  - 主要是使用 `struct` 和 `interface` 来实现类似功能
  ```go
    type Animal struct {
        Name string
    }
  
    func (a *Animal) Eat() {
        fmt.Println("Animal is eating")
    }
  
    type Dog struct {
        Animal // 通过嵌入 Animal 结构体来继承
        Breed string
    }
  
    func main() {
        dog := Dog{
            Animal: Animal{"Dog"},
            Breed: "Labrador",
        }
  
        dog.Eat()
    }

  ```
  
### 模块
模块下不能有多个 `main`, 会认为是函数重复，可以将他们放到不同的文件夹下面解决这个问题