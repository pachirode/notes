# 静态代码审查工具

### 安装
```bash
go get github.com/golangci/golangci-lint/cmd/golangci-lint@v1.50.1
golangci-lint version
```

### 命令
- 子命令
  - `cache`
    - 缓存控制，打印缓存信息
    - `clean`
    - `status`
  - `completion`
  - `config`
    - 当前使用的配置文件路径
  - `help`
  - `linters`
  - `run`
  - `version`
- 全局选项
  - `--color`
  - `j, --concurrency`
    - 开启并发数量
  - `--cup-profile-path`
  - `--mem-profile-path`
  - `--trace-path`

##### 使用
```bash
golangci-lint run # 对当前目录及子目录下所有文件进行静态代码审查
golangci-lint run dir # 指定目录
golangci-lint run -c .golangci.yaml ./ # 指定配置文件
golangci-lint run --no-config --disable-all -E errcheck ./ # 仅开启一个
```
> 默认情况下会从当前目录下一层层向上寻找配置文件 `--no-config` 关闭读取

- `-D`
  - 禁用某些 `linter`
- `-e` 配置文件 `issues.exclude-rules`；源码 `//nolint`
  - 减少误报
- `--new-from-rev`
  - 只检查新增的代码


```go
var bad_name int //nolint
var bad_name int //nolint:golint,unused
//nolint:govet
var (
a int
b int
)
```