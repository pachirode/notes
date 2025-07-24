# 日志包

### 设计日志

##### 基础功能

- 基本的日志信息
    - 时间戳
    - 文件名
    - 行号
    - 日志级别
    - 日志信息
- 支持不同级别的日志
    - `Trace`
        - 更加详细日志，不是必需的
    - `Debug`
    - `Info`
    - `Warn`
    - `Error`
    - `Panic`
    - `Fatal`
- 日志级别
    - 输出级别
    - 开关级别
        - 希望哪些级别的日志被输出
- 支持自定义级别
    - 输出 `JSON` 格式或者 `Text` 格式日志
- 支持标准输出和文件

##### 进阶功能

- 支持多种日志格式
- 按级别分类输出
- 支持结构化日志
- 支持日志轮转
- 支持 `Hook`
    - 某个级别日志产生时，发送邮件警告

##### 可选功能

- 支持颜色输出
- 兼容标准库 `log`
- 支持输出到不同位置

##### 注意

- 高性能
- 并发安全
- 插件化能力
- 日志参数控制

##### 记录日志

- 记录点
    - 分支语句
    - 写操作
    - 错误产生最原始的位置
        - 循环中需要考虑
- 日志内容
    - 不包含敏感信息
    - 方便调试可以使用特殊字符开头
    - 使用明确的类型
    - 请求 `ID` 和用户行为

### 分布式日志解决方法 `EFK`

`Elasticsearch + Filebeat + Kibana`
```mermaid
flowchart LR
    data_source --> shipper --> Kafka --> Logstash --> Elasticsearch --> Kibana
```

- `shipper` 收集日志
  - `Logstash Shipper`
  - `Flume`
  - `Fluentd`
  - `Filebeat`