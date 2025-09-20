# `nginx`

轻量级，高性能的反向代理和负载均衡工具

注意
- 使用 `upstream` 管理后端服务，便于扩展
- 路径和末尾不能使用 `/` 影响代理行为
- `proxy_set_header` 保留原始请求信息
  - 安全
  - 日志

### 安装

源码编译可以打开所有模块

默认配置文件路径 `/usr/local/nginx/conf/nginx.conf`
启动 `Nginx` `/usr/local/nginx/sbin/nginx`

### 反向代理

##### http

[HTTP 反向代理](demo/nginx/http/nginx.conf)

- `proxy_pass`
    - 设置转发的目标地址
- `proxy_set_header`
    - 设置转发请求头，保留用户真实信息
- `upstream`
    - 定义后端服务池，可以添加多个 `IP` 做负载均衡

##### https

[HTTPS 反向代理](demo/nginx/https/nginx.conf)

- `ssl_certificate` `ssl_certificate_key`
  - 指定 `SSL` 证书及私钥路径，用于启动 `HTTPS`
- `ssl_prefer_server_ciphers on`
  - 优先使用服务器定义加密套件
- `ssl_session_cache`
  - 开启 `ssl` 会话缓存，提高性能
- `ssl_session_timeout`
  - 定义会话缓存超过时间
- `Vary 'Origin'`
  - 提示浏览器或 CDN，缓存应根据 Origin 变化分别处理
  - 统一资源来自不同的 `origin`，可能需要不同的缓存内容
- `proxy_redirect off`
  - 关闭默认重定向，防止干扰代理响应地址

##### websocket

`WebSocket` 使用 `HTTP` 协议升级机制，必须设置相关头信息，才能正确代理

客户端请求
- 发送一个 `HTTP`，请求升级到 `WebSocket`
  - `Upgrade: websocket`
  - `Connection: Upgrade`
  - `Sec-WebSocket-Key`
  - `Sec-WebSocket-Version`

[WebSocket 代理](demo/nginx/websocket/nginx.conf)

- `proxy_http_version 1.1`
  - `webSocket` 需要使用 `HTTP/1.1`
- `Upgrade / Connection` 头
  - 建立持久连接
- `/ws`
  - 自定义路由前缀

##### tcp

[TCP 代理](demo/nginx/tcp/nginx.conf)

需要开启 `--with-stream` 模块，需要编译的时候启用

应用场景
- `MySQL`
- `Redis`
- `RabbitMQ`
- `Kafka`


##### 本地静态文件

[静态文件代理](demo/nginx/static-file/nginx.conf)

将静态文件放入对应目录，如何直接访问代理地址

