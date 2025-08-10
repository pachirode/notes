# Curl

### 常用参数
- `-X/--request [GET|POST|PUT|DELETE|...]` 指定请求方法
  - `-d` 发送 `POST` 数据
  - `-G -d` 数据作为 `GET` 参数发送 
- `-H/--header`
- `-d/--data` 指定请求的消息体
- `-v/--verbose` 输出详细的返回信息
- `-u/--user` 指定账户密码
- `-b/--cookie` 
- `-o` 将输出保存到文件
- `-O` 使用远程文件名保存
- `-s` 静默模式

### 案例

```bash
# 获取网页内容
curl https://www.example.com

# 下载文件
curl -O https://example.com/files/document.pdf

# 发送POST请求
curl -X POST -d "username=admin&password=123456" https://api.example.com/login

# 保持 Cookie 会话
curl -c cookies.txt -b cookies.txt https://member.example.com
```

### 使用

```bash
# 登录获取 token
curl -s -XPOST -H"Authorization: Basic `echo -n 'admin:Admin'|base64`" http://127.0.0.1:8080/login | jq -r .token
# 设置环境变量便于后续使用
TOKEN=""
# 创建 secret
curl -v -XPOST -H "Content-Type: application/json" -H"Authorization: Bearer ${TOKEN}" -d'{"metadata":{"name":"secret0"},"expires":0,"description":"admin secret"}' v1/secrets
# 获取 secret 信息
curl -XGET -H"Authorization: Bearer ${TOKEN}" v1/secrets/secret0
```