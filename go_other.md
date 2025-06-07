# `Go` 库

### `Flag`

提供方便的接口来解析命令行参数

```go
// 格式一
variableName := flag.[T]("cmd name", "default value", "some descriptive information")

// 格式二
var variableName T
flag.[T]Var(&variableName, "cmd name", "default value", "some descriptive information")

func usage() {
fmt.Fprintf(os.Stderr, "Usage: %s [options] [args]\n", os.Args[0])
flag.PrintDefaults()
}

var debug = flag.Bool("debug", false, "Enable debug mode.")
flag.Usage = usage // 用于显示命令行标志参数的使用说明
flag.Parse()

```

##### `PFlag`

第三方库，使用方法和 `flag` 基本一致，提供了一些其他功能

- 可以设置别名

```go
var (
name    string
age     int
)

func init() {
pflag.StringVar(&name, "name", "defaultName", "the name to be used")
pflag.IntVarP(&age, "age", "a", 18, "the age of the person")
}

func main() {
// 解析命令行标志参数
pflag.Parse()
fmt.Println("name:", name, "age:", age)
}

```

### `Viper`

配置解析库，支持多种配置格式的解析和快速获取目标值

```yaml
IntKey: 101
Float64Key: 101.101
BoolKey: false
IntSliceKey:
  - 1
  - 2
  - 3
```

```go
import (
"github.com/spf13/viper"
)

func main() {
viper.SetConfigFile("config.yaml") // 指定配置文件路径
if err := viper.ReadInConfig(); err != nil {
// 处理读取配置文件失败的情况
log.Panicf("read conf error %s", err.Error())
}
println(viper.GetInt("IntKey"))
println(viper.GetFloat64("Float64Key"))

type MapKey struct {
Host string `json:"host"`
Port int    `json:"port"`
}
var mk MapKey
viper.UnmarshalKey("MapKey", &mk)
fmt.Printf("Map: %+v\n", mk)
}

viper.BindEnv("root", "GOROOT") // 绑定环境变量 GOROOT 到 root 这个Key上
viper.SetDefault("key", "default value") // 设置默认值

viper.WatchConfig() // 监听配置文件修改
viper.OnConfigChange(func (e fsnotify.Event) { // 监听配置文件修改事件，配置文件修改时触发
fmt.Println("config file changed:", e.Name)
fmt.Printf("String: %+v\n", viper.GetString("StringKey"))
})

```

### `Net/Http`

用于构建 `HTTP` 服务器和客户端

### `Context`

上下文，用来实现多函数中传递相关值，设置请求截止日期等的重要接口，与 `Goroutine` 一起可以实现对函数调用的链路控制

- `Deadline` 返回被取消的时间，也就是完成工作的截止日期；

- `Done` 返回一个 `Channel`，会在当前工作完成或者上下文被取消后关闭

- `Err` 返回 `Context` 结束的原因，它只会在 `Done` 方法对应的 `Channel` 关闭时返回非空的值；

    - 如果 `Context` 被取消，会返回 `context canceled` 错误；

    - 如果 `Context` 超时，会返回 `context deadline exceeded` 错误；

    - `Value` 从 `Context` 中获取键对应的值，对于同一个上下文来说，多次调用 Value 并传入相同的 Key
      会返回相同的结果，该方法可以用来传递请求特定的数据

### `Gin`

轻量级 `Web` 框架

- 请求方法
- 响应格式
    - `c.JSON` `c.YAML`
- 参数绑定
    - 路径参数
    - `Get Post` 参数
- 参数校验
- 文件上传
- 路由分组
- 中间件
- 自定义日志

```go
import (
"github.com/gin-gonic/gin"
)

func main() {
r := gin.Default()
r.GET("/ping", func (c *gin.Context) {
c.JSON(200, gin.H{ // 返回 Json 格式的数据
"pong": "pong"
})
})
}

func GetMethod(c *gin.Context) {
firstName := c.Query("firstName", "Guest") // 解析路由参数
lastName := c.DefaultQuery("lastName", "Gopher")
c.String(http.StatusOK, "Hello %s %s", firstName, lastName)
}

func PostMethod(c *gin.Context) {
nick := c.DefaultPostForm("nick", "anonymous") // 解析表单参数
message := c.PostForm("message")

c.JSON(200, gin.H{
"status":  "posted",
"message": message,
"nick":    nick,
})
}

func main() {
router := gin.Default()
router.GET("/welcome", GetMethod)
router.POST("/form", PostMethod)
}

// 绑定
type Person struct {
ID   string `uri:"id" binding:"required,uuid"`
Name string `uri:"name" binding:"required"`
}
if err := c.ShouldBindUri(&person); err != nil {
c.JSON(400, gin.H{"msg": err.Error()})
return
}

```

