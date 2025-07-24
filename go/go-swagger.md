# 生成 `Swagger` 文档

`OpenAPI` 是一个 `API` 规范，它的前身叫 `Swagger` 规范，通过定义一种用来描述 `API` 格式或定义的语言，来规范服务开发过程

- 对 `API` 的描述，介绍 `API` 可以实现的功能
- 可用路径（`/user`）和操作（`GET`）
- 输入和返回参数
- 验证方法
- 其他信息

### `go-swagger`

自动生成文档可以帮助我们节省时间
如果需要提供对外的 `SDK`，可使用自动生成客户端代码的功能

- 根据 `Swagger` 定义文件生成服务端代码
- 根据 `Swagger` 定义文件生成客户端代码
- 校验 `Swagger` 文件是否正确
- 启动一个 `HTTP` 服务器，可以通过浏览器访问 `API` 文档
- 根据 `Swagger` 文档定义参数生成 `Go model` 结构体定义

##### 安装

`go get -u github.com/go-swagger/go-swagger/cmd/swagger`

##### 命令行工具

`swagger` 命令格式 `swagger [OPTIONS] <command>`

- `diff`
    - 对比两个文档的区别
- `expand`
    - 展开 `Swagger` 文档中 `$ref`
- `flatten`
- `generate`
    - 生成文档，客户端代码，服务端代码等
- `ini`
    - 初始化定义文档，可以指定配置项
- `mix`
    - 合并文档
- `serv`
    - 启动 `HTTP`，查看文档
- `validate`
    - 验证定义文件

##### 常用注解

- `swagger:meta`
    - 定义接口全局基本信息
- `swagger:route`
- `swagger:parameters`
- `swagger:response`
- `swagger:model`
    - 可以复用的数据结构
- `swagger:allOf`
    - 嵌入其他结构体
- `swagger:strfmt`
- `swagger:ignore`

##### 生成文档

使用生成命令会先找到 `main` 函数，然后遍历所有源码，解析源码中与 `swagger` 相关的注释，自动生成 `swagger.json/swagger.yaml`

- `-o`
    - 指定输出文件名字，根据文件名后缀决定文件格式
- `-no-open`
    - 禁止调用浏览器打开 `URL`
- `-F`
    - 指定文档风格（`swagger` `redoc`）
- `-port`

```go
import (
"github.com/xx/swagger/docs" // 存放带有注释的 `API` 文档
)

type User struct {
// Required: true   生成文档时 这个字段是必须的
Name string `json:"name"`
}

// Package docs awesome. awesome 代表服务器的名字
//
// Documentation of our awesome API. API 描述
//
//     Schemes: http, https
//     BasePath: /
//     Version: 0.1.0
//     Host: some-url.com
//
//     Consumes:
//     - application/json
//
//     Produces:
//     - application/json
//
//     Security:
//     - basic
//
//    SecurityDefinitions:
//    basic:
//      type: basic
//
// swagger:meta 注释结束
package docs
```

```bash
swagger generate spec -o swagger.yaml
swagger serve --no-open -F=swagger --port 36666 swagger.yaml
```

```go
// API 接口
import (
"github.com/marmotedu/gopractise-demo/swagger/api"
)

// swagger:route POST /users user createUserRequest 接口描述开始
//                           tag(可以多个，用来分组)
// Create a user in memory. 接口描述，需要 . 结束
// responses:   定义返回参数
//   200: createUserResponse
//   default: errResponse

// swagger:route GET /users/{name} user getUserRequest
// Get a user from memory.
// responses:     
//   200: getUserResponse
//   default: errResponse

// swagger:parameters createUserRequest 具有相同 ID 的标识符
type userParamsWrapper struct {
// This text will appear as description of your request body.
// in:body  该参数是在HTTP Body中返回
Body api.User
}

// This text will appear as description of your request url path.
// swagger:parameters getUserRequest
type getUserParamsWrapper struct {
// in:path
Name string `json:"name"`
}
```

```bash
swagger diff -d change.log swagger.new.yaml swagger.old.yaml
swagger generate server -f ../swagger.yaml -A go-user
swagger generate client -f ../swagger.yaml -A go-user
swagger validate swagger.yaml
swagger mixin swagger_part1.yaml swagger_part2.yaml
```
