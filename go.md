# GO

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
        - `rune`
        - `uint`
        - `int`
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
    var indentifier1, indentifier2 type // 一次声明多个变量
    var v_name, v_type  // 指定变量类型，如果没有初始化，则变量会有默认值
    var v_name = value // 可以根据值自行判断变量类型
    v_name := value // 如果变量已经使用 `var` 声明过了，再使用 `:=` 声明，就会产生编译错误
  ```
- 值类型和引用类型
    - 值类型直接保存数据，赋值操作实际上是复制了这些值
    - 引用类型保存的是数据的地址，复制实际上复制了地址，最终指向同一个内存空间
- `:=` 赋值
    - 只能用在函数体内，不可以声明全局变量
  > 局部变量赋值必须使用；全局变量允许声明但是不使用
- 常量
    - 程序运行过程中不会被修改的量。

```go
package main

const (
	Unknow = 0
	Male   = 1
)

func main() {
	const LENGTH int = 10
}

```

- `iota`
    - 特殊变量，一个可以被编译器修改的常量
    - 通常用于创建一组相关的常量

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
- 条件语句
    - `if else`
    - `swith`
    - `select`
        - 只能用于通道操作，每个 `case` 必须是通道
        - 如果多个通道都准备好了，会随机选择一个通道执行
- 循环语句
- 函数
- 数组

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
fmt.Println(Book{"Go Programming", "XYZ", "Go Programming Tutorial", 6495407})
}
```
- 切片
  - 对数组的抽象，数组的长度不可改变，切片相当于 动态数组，可以追加元素
  - `len()` 当前长度
  - `cap()` 容量
  - `append()`
  - `copy()`
```go
var identifier []type // 声明一个未指定大小的切片
slice := make([]type, len) // 创建切片，capacity 为可选参数

// 切片扩容
number1 := make([]int, len(numbers), cap(numbers) * 2)
copy(number1, numbers)
```
> 切片和数组的区别：1. 数组大小（固定/动态）2.内存（数组定义的时候分配固定的内存，大概率在栈上。切片实际上一个结构体，底层数组可以在堆上）3. 数组传参时候会复制整个数组，切片传递的为引用 

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
  - `strconv`
```go
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
    - `panic` 和 `recover`
      - 处理不可恢复的严重的错误
      - `panic` 用于触发错误（用于程序无法继续运行时），`recover` 用于捕获错误
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