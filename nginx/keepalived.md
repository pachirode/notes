# Keepalived

通过虚拟 `IP` (`VIP`) 绑定多个节点，在主节点失效时自动切换，保障访问不会中断

### 配置

配置文件 `/etc/keepalived/keepalived.conf`，[案例](demo/keepalived/keepalived.conf)

- `state`
  - `MASTER`
    - 主节点
  - `BACKUP`
    - 备用节点
- `priority`
  - 备用节点的值需要小于主节点，谁优先级高谁是 `VIP`
  - 可以被 `track_script` 脚本动态降低
- `vrrp_instance`
  - 定义一个实例名
- `interface`
  - 使用网络接口绑定 `VIP`
  - 网卡需要能广播
- `virtual_router_id`
  - 虚拟路由 `id`
  - 同一组虚拟路由 `ID` 必须相同
- `advert_int`
  - 心跳间隔
  - 通告 `VRRP`
- `authentication`
  - 配置组之间认证
- `virtual_ipaddress`
  - 可选的 `VIP`
- `track_script`
  - 服务状态检测脚本
- `nopreempt`
  - 非抢占模式
  - 主节点恢复之后也不会主动抢回 `VIP`

# VRRP

提高网络路由可靠性的协议，允许多个物理路由器在同一个网络中协作，通过虚拟路由的方式提供冗余

### 虚拟路由器

创建一个虚拟路由器，虚拟路由器具有一个虚拟的 `IP` 地址，这个 `IP` 是网络中各个主机的默认网关
多个物理路由器共享这个虚拟路由器的 `IP` 地址，但是只有一个物理路由器充当主路由

### 主路由和备份路由

选举一个路由器作为主路由，它负责处理所有通过虚拟 `IP` 发送的数据包
其他路由监视主路由状态

### 选举机制

使用优先级来决定哪台路由器成为主路由
如果当前主路由故障，会选举出新的主路由