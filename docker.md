# VM

##### 虚拟机网络配置
新安装完成的 `Centos7` 无法访问网络
```bash
vim /etc/sysconfig/network-scripts/ifcfg-ens33
ONBOOT=yes
service network restart
```
修改为国内镜像源
```bash
cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
vim /etc/yum.repos.d/CentOS-Base.repo

""""
# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the 
# remarked out baseurl= line instead.
#
#
 
[base]
name=CentOS-$releasever - Base - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/$releasever/os/$basearch/
        http://mirrors.aliyuncs.com/centos/$releasever/os/$basearch/
        http://mirrors.cloud.aliyuncs.com/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7
 
#released updates 
[updates]
name=CentOS-$releasever - Updates - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/$releasever/updates/$basearch/
        http://mirrors.aliyuncs.com/centos/$releasever/updates/$basearch/
        http://mirrors.cloud.aliyuncs.com/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7
 
#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/$releasever/extras/$basearch/
        http://mirrors.aliyuncs.com/centos/$releasever/extras/$basearch/
        http://mirrors.cloud.aliyuncs.com/centos/$releasever/extras/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7
 
#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/$releasever/centosplus/$basearch/
        http://mirrors.aliyuncs.com/centos/$releasever/centosplus/$basearch/
        http://mirrors.cloud.aliyuncs.com/centos/$releasever/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7
 
#contrib - packages by Centos Users
[contrib]
name=CentOS-$releasever - Contrib - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/$releasever/contrib/$basearch/
        http://mirrors.aliyuncs.com/centos/$releasever/contrib/$basearch/
        http://mirrors.cloud.aliyuncs.com/centos/$releasever/contrib/$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7

""""
yum clean all
yum makecache

```
安装 miniconda
```bash
yum -y install bzip2
wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda-3.10.1-Linux-x86_64.sh
bash Miniconda-3.10.1-Linux-x86_64.sh

conda info # 查看镜像源
conda config --remove channels http://mirrors.aliyun.com/anaconda/pkgs/main --force
conda config --add channels http://mirrors.aliyun.com/anaconda/cloud
conda config --set show_channel_urls yes
```

安装 docker & docker compose
```bash
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
systemctl start docker #启动docker
systemctl enable docker

yum install -y  docker-compose-plugin
```

##### 虚拟机扩容

1. 关闭虚拟机
2. 硬盘扩展
3. 启动虚拟机查看磁盘信息
4. `fdisk -l` 查看磁盘
5. `fdisk /etc/sda` 回车；`w` 写入
6. 修改新分区 `id` 到 `LVM id` 
   - `fdisk /dev/sda`
   - `t;id;l;lvm_id;w`
   - 重启
7. 扩容分区
   - `lvs` 查看逻辑卷
   - `vgdisplay` 显示卷组信息
   - `pvcreate /dev/sda3` 物理硬盘初始化为物理卷
   - `vgextend centos /dev/sda3` 扩展卷
8. 扩充逻辑卷
   - `lvextend -L+100G /dev/centos/root /dev/sda3`
9. 重设逻辑卷大小
   - `xfs_growfs  /dev/centos/root`


# Docker

### Centos 7

##### 安装
1. 添加 `docker` 镜像源 `sudo yum-config-manager --remove-repo https://download.docker.com/linux/centos/docker-ce.repo`
2. `sudo yum install docker-ce docker-ce-cli containerd.io`

> 新版的 `docker` 需要包装系统版本（uname -r > 3.10）
> `yum list docker-ce --showduplicates | sort -r` 查看所有版本；`yum install docker-ce-<VERSION_STRING> docker-ce-cli-<VERSION_STRING> containerd.io`


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