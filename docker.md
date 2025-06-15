# Docker

轻量化容器结构，一个应用一个容器

### 技术实现

- 命名空间
    - 软件资源的隔离
    - 在 `Linux` 中命名空间是一种内核特性，用于隔离系统资源，使得各个进程互不干扰
- 控制组
    - 主要负责硬件资源的隔离
    - `CPU` 内存等资源限制，资源优先级
- 联合文件系统
    - 允许多个文件挂载到一个单一的目录结构中
    - 层叠结构，通过将多个文件系统层叠在一起，形成一个同一的目录读写权限可以单独设置

### 基本组件

- 镜像
    - 只读文件包，虚拟环境运行最原始的文件系统
    - 增量式的镜像结构，本质上镜像是无法修改的
- 容器
    - 隔离出来的虚拟环境
- 网络
    - 可以容器间建立虚拟局域网
    - 建立独立的域名解析环境
- 数据卷
    - 除了挂载目录还可以使用目录持久化数据
    - 容器间共享数据
- `Docker Engine`
    - `docker daemon`
        - 容器管理
        - 应用编排
        - 镜像分发
    - `docker CLI`
        - 对外暴露接口可以操作 `docker daemon`

##### 镜像

镜像由不同的镜像层组成，每一个镜像层都拥有唯一 `Hash` 编码，允许在镜像之间共享镜像层

- `docker inspect`
    - 获取镜像的详细信息
- `docker commit -m "Configured" webapp`
    - 提交容器更改，需要先暂停容器运行
- `docker save webapp:1.0 > webapp-1.0.tar`
    - 保存镜像
- `docker load < webapp-1.0.tar`
    - 导入镜像

##### 容器

- 主进程
    - 容器的生命周期和容器中 `PID` 为 1 的进程一致
- 写时复制
    - 允许多个容器共享相同的基础镜像，只有对数据进行修改的时候才会创建新的副本
- `docker attach`
    - 连接一个正在运行的容器的标准输入输出

网络配置

- 沙盒
    - 为每个容器创建一个独立的网络
- 网络
- 端点
    - 容器在网络中的连接点

网络驱动

- `bridge`
    - 默认
    - 创建时如果不指定网络都会连接到此处
- `host`
- `overlay`
    - 跨物理机的虚拟网络
- `macvlan`
- `none`
- 创建网络
    - `docker network create -d` 指定驱动类型，默认 `bridge`

容器互联

- 创建容器的时候使用 `--link`
- 容器处在不同网络无法互联

端口

- 端口暴露
    - 只有容器自身允许的端口才能被其他容器访问
- 端口映射

##### 数据管理

沙盒文件系统数据无法持久化；容器隔离使得内外数据很难流通

文件挂载

- `Bind Mount`
    - 将宿主机操作系统中的目录和文件挂载到容器内，容器内外对文件读写互相可见
- `Volume`
    - 宿主机挂载目录到容器，由 `Docker` 管理
    - 数据卷命名唯一，可以多个容器共享
- `Tmpfs`
    - 挂载系统内存到容器
- 数据卷容器
    - 没有具体的应用不需要允许，为了定义一个或者多个数据卷并持有它们的引用
- 备份迁移数据卷
    - `> docker run --rm --volumes-from appdata -v /backup:/backup ubuntu tar cvf /backup/backup.tar /webapp/storage`
    - `> docker run --rm --volumes-from appdata -v /backup:/backup ubuntu tar xvf /backup/backup.tar -C /webapp/storage --strip`
    - 创建一个打包文件的目录 `/backup`
    - 创建一个临时容器挂载备份目录和数据卷

### Centos 7

##### 安装

1. 添加 `docker` 镜像源 `sudo yum-config-manager --remove-repo https://download.docker.com/linux/centos/docker-ce.repo`
2. `sudo yum install docker-ce docker-ce-cli containerd.io`

> 新版的 `docker` 需要包装系统版本（uname -r > 3.10）
> `yum list docker-ce --showduplicates | sort -r`
> 查看所有版本；`yum install docker-ce-<VERSION_STRING> docker-ce-cli-<VERSION_STRING> containerd.io`

##### 卸载

1. 检查 `docker` 状态 `systemctl status docker`
2. 停止 `systemctl stop docker`
3. 查看 `yum` 所有安装包 `yum list installed | grep docker`
4. 查看 `docker` 相关的 `rpm` 资源 `rpa -qa | grep docker`
5. 输出相关 `rpm` 资源，`yum -y remove <rpm>`
6. 删除 `docker` 镜像文件，默认 `/var/lib/docker`

##### 修改镜像源

1. `vim /etc/docker/daemon.json`

```bash
{
"registry-mirrors": [
 "https://docker.m.daocloud.io", 
 "https://noohub.ru", 
 "https://huecker.io",
 "https://dockerhub.timeweb.cloud",
 "https://0c105db5188026850f80c001def654a0.mirror.swr.myhuaweicloud.com",
 "https://5tqw56kt.mirror.aliyuncs.com",
 "https://docker.1panel.live",
 "http://mirrors.ustc.edu.cn/",
 "http://mirror.azure.cn/",
 "https://hub.rat.dev/",
 "https://docker.ckyl.me/",
 "https://docker.chenby.cn",
 "https://docker.hpcloud.cloud",
 "https://docker.m.daocloud.io"
]
}
```

##### 代理

1. 创建 `drop-in` 文件
2. `mkdir -p /etc/systemd/system/docker.service.d` & `vim /etc/systemd/system/docker.service.d/http-proxy.conf`
3. ```bash
   [Service]
    Environment=HTTP_PROXY=http://192.168.1.1:8080
    Environment=HTTPS_PROXY=http://192.168.1.1:8080
    Environment=NO_PROXY=localhost,127.0.0.1,docker-registry.example.com
   ```
4. 重启 `systemctl daemon-reload` & `systemctl restart docker`
5. 验证 `systemctl show --property=Environment docker`

##### 故障

- `systemctl start docker`
    - `Job for docker.service failed because the control process exited with error code. See "systemctl status docker.service" and "journalctl -xe" for details.`
    - `tail -200f /var/log/messages`
        - 查看 `Linux` 系统操作日志，再次启动 `docker` 服务

### 部署 `Django` 项目

- 容器组合
    - `Django + Uwsgi`
    - `MySQL`
    - `Redis`
    - `Nginx`
- 项目格式
    - `compose`
        - `uwsgi` 挂载容器内 `uwsgi` 日志
        - `mysql`
            - `conf`
                - `my.cnf` `MySql` 配置文件
            - `init`
                - `init.sql`
        - `redis`
            - `redis.conf`
        - `nginx`
            - `Dockerfile`
            - `log` 挂载日志
            - `nginx.conf`
            - `ssl` 配置 `https`
    - `docker-compose.yml`
    - `django` 项目

```yaml
version: "3"

volumes: # 自定义数据卷
  db_vol: #定义数据卷同步存放容器内mysql数据
  redis_vol: #定义数据卷同步存放redis数据
  media_vol: #定义数据卷同步存放web项目用户上传到media文件夹的数据
  static_vol: #定义数据卷同步存放web项目static文件夹的数据

networks: # 自定义网络(默认桥接), 不使用links通信
  nginx_network:
    driver: bridge
  db_network:
    driver: bridge
  redis_network:
    driver: bridge

services:
  redis:
    image: redis:latest
    command: redis-server /etc/redis/redis.conf # 容器启动后启动redis服务器
    networks:
      - redis_network
    volumes:
      - redis_vol:/data # 通过挂载给redis数据备份
      - ./compose/redis/redis.conf:/etc/redis/redis.conf # 挂载redis配置文件
    ports:
      - "6379:6379"
    restart: always # always表容器运行发生错误时一直重启

  db:
    image: mysql
    env_file:
      - ./myproject/.env # 使用了环境变量文件
    networks:
      - db_network
    volumes:
      - db_vol:/var/lib/mysql:rw # 挂载数据库数据, 可读可写
      - ./compose/mysql/conf/my.cnf:/etc/mysql/my.cnf # 挂载配置文件
      - ./compose/mysql/init:/docker-entrypoint-initdb.d/ # 挂载数据初始化sql脚本
    ports:
      - "3306:3306" # 与配置文件保持一致
    restart: always

  web:
    build: ./myproject
    expose:
      - "8000"
    volumes:
      - ./myproject:/var/www/html/myproject # 挂载项目代码
      - static_vol:/var/www/html/myproject/static # 以数据卷挂载容器内static文件
      - media_vol:/var/www/html/myproject/media # 以数据卷挂载容器内用户上传媒体文件
      - ./compose/uwsgi:/tmp # 挂载uwsgi日志
    networks:
      - nginx_network
      - db_network
      - redis_network
    depends_on:
      - db
      - redis
    restart: always
    tty: true
    stdin_open: true

  nginx:
    build: ./compose/nginx
    ports:
      - "80:80"
      - "443:443"
    expose:
      - "80"
    volumes:
      - ./compose/nginx/nginx.conf:/etc/nginx/conf.d/nginx.conf # 挂载nginx配置文件
      - ./compose/nginx/ssl:/usr/share/nginx/ssl # 挂载ssl证书目录
      - ./compose/nginx/log:/var/log/nginx # 挂载日志
      - static_vol:/usr/share/nginx/html/static # 挂载静态文件
      - media_vol:/usr/share/nginx/html/media # 挂载用户上传媒体文件
    networks:
      - nginx_network
    depends_on:
      - web
    restart: always
```

```dockerfile
# 建立 python 3.9环境
FROM python:3.9

# 安装netcat
RUN apt-get update && apt install -y netcat

# 设置 python 环境变量
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# 可选：设置镜像源为国内
COPY pip.conf /root/.pip/pip.conf

# 容器内创建 myproject 文件夹
ENV APP_HOME=/var/www/html/myproject
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

# 将当前目录加入到工作目录中（. 表示当前目录）
ADD . $APP_HOME

# 更新pip版本
RUN /usr/local/bin/python -m pip install --upgrade pip

# 安装项目依赖
RUN pip install -r requirements.txt

# 移除\r in windows
RUN sed -i 's/\r//' ./start.sh

# 给start.sh可执行权限
RUN chmod +x ./start.sh

# 数据迁移，并使用uwsgi启动服务
ENTRYPOINT /bin/bash ./start.sh
```

```shell
#!/bin/bash
# 从第一行到最后一行分别表示：
# 1. 等待MySQL服务启动后再进行数据迁移。nc即netcat缩写
# 2. 收集静态文件到根目录static文件夹，
# 3. 生成数据库可执行文件，
# 4. 根据数据库可执行文件来修改数据库
# 5. 用 uwsgi启动 django 服务
# 6. tail空命令防止web容器执行脚本后退出
while ! nc -z db 3306 ; do
    echo "Waiting for the MySQL Server"
    sleep 3
done

python manage.py collectstatic --noinput&&
python manage.py makemigrations&&
python manage.py migrate&&
uwsgi --ini /var/www/html/myproject/uwsgi.ini&&
tail -f /dev/null

exec "$@"
```

```ini
[uwsgi]

project = myproject
uid = www-data
gid = www-data
base = /var/www/html

chdir = %(base)/%(project)
module = %(project).wsgi:application
master = True
processes = 2

socket = 0.0.0.0:8000
chown-socket = %(uid):www-data
chmod-socket = 664

vacuum = True
max-requests = 5000

pidfile = /tmp/%(project)-master.pid
daemonize = /tmp/%(project)-uwsgi.log

#设置一个请求的超时时间(秒)，如果一个请求超过了这个时间，则请求被丢弃
harakiri = 60
post buffering = 8192
buffer-size = 65535
#当一个请求被harakiri杀掉会，会输出一条日志
harakiri-verbose = true

#开启内存使用情况报告
memory-report = true

#设置平滑的重启（直到处理完接收到的请求）的长等待时间(秒)
reload-mercy = 10

#设置工作进程使用虚拟内存超过N MB就回收重启
reload-on-as = 1024
```

```dockerfile
# nginx镜像compose/nginx/Dockerfile

FROM nginx:latest

# 删除原有配置文件，创建静态资源文件夹和ssl证书保存文件夹
RUN rm /etc/nginx/conf.d/default.conf \
&& mkdir -p /usr/share/nginx/html/static \
&& mkdir -p /usr/share/nginx/html/media \
&& mkdir -p /usr/share/nginx/ssl

# 设置Media文件夹用户和用户组为Linux默认www-data, 并给予可读和可执行权限,
# 否则用户上传的图片无法正确显示。
RUN chown -R www-data:www-data /usr/share/nginx/html/media \
&& chmod -R 775 /usr/share/nginx/html/media

# 添加配置文件
ADD ./nginx.conf /etc/nginx/conf.d/

# 关闭守护模式
CMD ["nginx", "-g", "daemon off;"]
```

```ngix.conf
upstream django {
    ip_hash;
    server web:8000; # Docker-compose web服务端口
}

# 配置http请求，80端口
server {
    listen 80; # 监听80端口
    server_name 127.0.0.1; # 可以是nginx容器所在ip地址或127.0.0.1，不能写宿主机外网ip地址

    charset utf-8;
    client_max_body_size 10M; # 限制用户上传文件大小

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;

    location /static {
        alias /usr/share/nginx/html/static; # 静态资源路径
    }

    location /media {
        alias /usr/share/nginx/html/media; # 媒体资源，用户上传文件路径
    }

    location / {
        include /etc/nginx/uwsgi_params;
        uwsgi_pass django;
        uwsgi_read_timeout 600;
        uwsgi_connect_timeout 600;
        uwsgi_send_timeout 600;

        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_redirect off;
        proxy_set_header X-Real-IP  $remote_addr;
       # proxy_pass http://django;  # 使用uwsgi通信，而不是http，所以不使用proxy_pass。
    }
}
```

```my.cnf
[mysqld]
user=mysql
default-storage-engine=INNODB
character-set-server=utf8
secure-file-priv=NULL # mysql 8 新增这行配置
default-authentication-plugin=mysql_native_password  # mysql 8 新增这行配置

port            = 3306 # 端口与docker-compose里映射端口保持一致
#bind-address= localhost #一定要注释掉，mysql所在容器和django所在容器不同IP

basedir         = /usr
datadir         = /var/lib/mysql
tmpdir          = /tmp
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
skip-name-resolve  # 这个参数是禁止域名解析的，远程访问推荐开启skip_name_resolve。

[client]
port = 3306
default-character-set=utf8

[mysql]
no-auto-rehash
default-character-set=utf8
```

```init.sql
Alter user 'dbuser'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
GRANT ALL PRIVILEGES ON myproject.* TO 'dbuser'@'%';
FLUSH PRIVILEGES;
```

```.env
MYSQL_ROOT_PASSWORD=123456
MYSQL_USER=dbuser
MYSQL_DATABASE=myproject
MYSQL_PASSWORD=password
```

```redis
# compose/redis/redis.conf
# Redis 5配置文件下载地址
# https://raw.githubusercontent.com/antirez/redis/5.0/redis.conf

# 请注释掉下面一行，变成#bind 127.0.0.1,这样其它机器或容器也可访问
bind 127.0.0.1

# 取消下行注释，给redis设置登录密码。这个密码django settings.py会用到。
requirepass yourpassword
```

```python
# 生产环境设置 Debug = False
Debug = False

# 设置ALLOWED HOSTS
ALLOWED_HOSTS = ['your_server_IP', 'your_domain_name']

# 设置STATIC ROOT 和 STATIC URL
STATIC_ROOT = os.path.join(BASE_DIR, 'static')
STATIC_URL = "/static/"

# 设置MEDIA ROOT 和 MEDIA URL
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
MEDIA_URL = "/media/"

# 设置数据库。这里用户名和密码必需和docker-compose.yml里mysql环境变量保持一致
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'myproject',  # 数据库名
        'USER': 'dbuser',  # 你设置的用户名 - 非root用户
        'PASSWORD': 'password',  # # 换成你自己密码
        'HOST': 'db',  # 注意：这里使用的是db别名，docker会自动解析成ip
        'PORT': '3306',  # 端口
    }
}

# 设置redis缓存。这里密码为redis.conf里设置的密码
CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": "redis://redis:6379/1",  # 这里直接使用redis别名作为host ip地址
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
            "PASSWORD": "yourpassword",  # 换成你自己密码
        },
    }
}
```

