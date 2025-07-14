# `Go` 命令

### `go build`

用于编译我们指定的源码文件或代码包以及他们的依赖包，如果我们执行命令后面不跟着任何代码包，那么会试图编译当前目录对应的代码包
在编译只包含库源码文件的代码包时，只会做检查性的编译，不会输出结果文件
不能编译包含多个命令源码文件的代码包，也不能同时编译多个命令源码文件

```bash
go build showds.go initpkg_demo.go
# command-line-arguments
./initpkg_demo.go:19: main redeclared in this block
      previous declaration at ./showds.go:56
```

> `# command-line-arguments` 如果导入的是包的话这边显示的是导包路径，如果导入的第一个参数为源码文件会在内部生成一个虚拟的代码包

命令在执行时，编译程序会先查找目标代码的所有依赖包，以及他们的依赖包，如果发现有循环依赖，程序就会输出错误信息并立即退出；总体的逻辑为：依赖代码包 ->
当前代码包 -> 触发代码包

##### 参数

- `-v`
    - 打印那些被编译的代码包名字
- `-o`
    - 指定输出文件的名称
- `-work`
    - 打印编译时生成的临时工作路径，并在编译结束时保留
- `-p n`
    - 指定编译过程中执行各任务的并行数量，默认数量等于 `CPU` 逻辑核数
- `-n`
    - 打印期间所有命令，但是不真正执行
- `-x`
    - 打印所有命令

### `go fix` 和 `go tool fix`

`go fix` 会把指定代码包的所有源码文件中的旧版本修改为新版本不包括其子代码包；修正包括调用代码，语法等
`go fix` 是 `go tool fix` 的简单封装，它不处理参数，只是将参数简单的传递

##### 参数

- `-diff`
    - 不将修正后的文件内容写入，而只是打印前后内容对比
- `-r`
    - 只对目标源码文件做有限的修正
- `-force`

### `go vet` 和 `go tool vet`

检查源码中静态错误的简单工具

参数为代码包的导入路径或者是源码文件的绝对路径或者相对路径，但是不可混用
它首先会载入和分析指定的代码包，并把指定代码包中的所有源码文件和以 `.s` 结尾的文件相对路径作为参数传递给 `go tool vet`

### `go tool pprof`

交互式的访问概要文件的内容。命令分析指定的概要文件，根据要求提供高可读性的输出信息

通过标准库 `runtime` 和 `runtime/pprof` 中的程序生成包含实时性数据的概要文件；默认情况下 `Go` 语言运行时系统会以 100 `Hz`
的频率对 `CPU` 使用情况进行抽样

- `CPU` 概要文件
    - 对 `CPU` 使用情况就是对当前 `Goroutine` 堆栈上的程序计数器取样
- 内存概要文件
    - 程序运行过程中堆内存的分配情况
- 程序阻塞概要文件
    - 用于保护用户程序中的 `Goroutine` 阻塞事件记录

```go
// CPU
func startCPUProfile() {
if *cpuprofile != "" {
f, err := os.Create(*cpuprofile)
if err != nil {
fmt.Println("could not create CPU profile: ", err)
return
}

if err := pprof.StartCPUProfile(f); err != nil {
fmt.Println("could not start CPU profile: ", err)
f.Close()
return
}
}
}

func stopCPUProfile() {
if *cpuprofile != "" {
pprof.StopCPUProfile()
}
}

// Mem
func startMemProfile() {
if *memProfile != "" && *memProfileRate > 0{
runtime.MemProfileRate = *memProfileRate
}
}

func stopMemProfile() {
if *memProfile != "" {
f, err := os.Create(*memProfile)
if err != nil {
fmt.Println("could not create memory profile: ", err)
return
}
if err := pprof.WriteHeapProfile(f); err != nil {
fmt.Println("could not write memory profile: ", err)
}
f.Close()
}
}

// Block
func startBlockProfile() {
if *blockProfile != "" && *blockProfileRate > 0{
runtime.SetBlockProfileRate(*blockProfileRate)
}
}

func stopBlockProfile() {
if *blockProfile != "" && *blockProfileRate > 0{
f, err := os.Create(*blockProfile)
if err != nil {
fmt.Println("could not create block profile: ", err)
return
}
if err := pprof.Lookup("block").WriteTo(f, 0); err != nil {
fmt.Println("could not write block profile: ", err)
}
f.Close()
}
}

```

### `go tool cgo`

可以用来封装一些 `C` 语言的代码库源码文件
执行 `go tool cgo` 命令时，需要加入作为目标的 `Go`
源码文件，可以时绝对路径或者相对路径；推荐在目标源码文件所属的代码包目录下执行 `go tool cgo` 命令并以目标源码文件的名字作为参数
源码文件必需要包含一行针对代码包的导入语句 `// #include <stdlib.h>`

### `go env`

用于打印 `Go` 语言的环境信息

- `CGO_ENABLED`
  - `cgo` 工具是否可用
- `GOBIN`
  - 存放可执行文件的目录的绝对路径，安装源码文件产生的可执行文件会存放在此处
- `GOEXE`
  - 作为可执行文件的后缀，`window` 上为 `.exe`
