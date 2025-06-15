# VM

### 虚拟机网络

虚拟机的网络配置是通过虚拟网络适配器来实现的，这些适配器模拟物理网络接口卡

三种模式

- 桥接
    - 虚拟机可以直接连接到宿主机所在的物理网络中
    - 该模式下虚拟机和宿主机有同等地位，可以各自独立获取 `IP` 地址
- `NAT`
    - 多个虚拟机共享宿主机的一个 `IP` 地址来访问外部网络，外部只能看到宿主机，不知道虚拟机的存在
    - 双向通讯限制
- 仅主机
    - 创建一个完全隔离的私有网络环境，只有宿主机和在这个模式下的虚拟机可以相互通信

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
    - `xfs_growfs /dev/centos/root`

# 网络

数据包传输流程

- 发送数据
- 查找路由表
- 查 `ARP` 表
    - 下一步的 `MAC` 地址
- 查转发表
    - 实际发送数据

- `MAC` 地址表
    - 二层交换机为主，查询目的 `MAC` 地址对应的接口
    - 只负责本地局域网转发
    - 场景
        - 局域网内 `ping`，决定帧从哪个接口出去
        - `Mac` 绑定安全策略
    - 无法解析 `IP`
- `APR`
    - 三层接口有 `IP` 的设备，去找和 `MAC` 对饮的 `IP`
    - 知道 `IP` 包，但是不知道下一步 `MAC` 地址
    - 场景
        - 不同 `VLAN` 间通信
    - `ARP` 表中的 `MAC`，不代表一定在 `MAC` 表里面，需要交换机也见过这个 `MAC`
- 路由表
    - 三层交换机或者路由器，目的 `IP` 应该往哪里走
    - 不看 `MAC`，看 `IP` 决定转发的方向
    - 场景
        - `VLAN` 间通讯
        - 外网
    - 只提供方向，不会实际发送
- 转发表
    - 所有有转发能力的设备，把数据真正送出去

- 问题排查
    - 本地 `ping` 不同
        - `MAC` + `ARP`
    - `VLAN` 间通讯
        - 路由 + `ARP`
    - 默认路由没出去
        - 路由 + 转发表
    - 两台电脑互通无法转发
        - `MAC` 表