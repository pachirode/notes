# Centos8

### 配置基础环境

##### 创建用户

```bash
useradd other
passwd other

sed -i '/^root.*ALL=(ALL).*ALL/a\goer\tALL=(ALL) \tALL' /etc/sudoers
```

```bash
# .bashrc
# User specific aliases and functions
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi
if [ ! -d $HOME/workspace ]; then
    mkdir -p $HOME/workspace
fi
# User specific environment
# Basic envs
export LANG="en_US.UTF-8" # 设置系统语言为 en_US.UTF-8，避免终端出现中文乱码
export PS1='[\u@dev \W]$ ' # 默认的 PS1 设置会展示全部的路径，为了防止过长，这里只展示："用户名@dev 最后的目录名"
export PATH=$HOME/bin:$PATH # 将 $HOME/bin 目录加入到 PATH 变量中
```

##### 设置镜像源

```bash
mv /etc/yum.repos.d /etc/yum.repos.d.bak
mkdir /etc/yum.repos.d
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo
yum clean all && yum makecache
```

##### 安装常用软件

```bash
sudo yum -y install make autoconf automake cmake perl-CPAN libcurl-devel libtool gcc gcc-c++ glibc-headers zlib-devel git-lfs telnet lrzsz jq expat-devel openssl-devel openssl wget
```

### `git`

```bash
cd /tmp
wget --no-check-certificate https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.36.1.tar.gz
tar -xvzf git-2.36.1.tar.gz
cd git-2.36.1/
./configure
make
sudo make install

tee -a $HOME/.bashrc <<'EOF'
# Configure for git
export PATH=/usr/local/libexec/git-core:$PATH
EOF

git config --global user.name
git config --global user.email
git config --global credential.helper store
git config --global core.longpaths true
```

### `go`
```bash
wget -P /tmp/ https://go.dev/dl/go1.19.4.linux-amd64.tar.gz
mkdir -p $HOME/go
tar -xvzf /tmp/go1.19.4.linux-amd64.tar.gz -C $HOME/go
mv $HOME/go/go $HOME/go/go1.19.4
tee -a $HOME/.bashrc <<'EOF'
# Go envs
export GOVERSION=go1.19.4 # Go 版本设置
export GO_INSTALL_DIR=$HOME/go # Go 安装目录
export GOROOT=$GO_INSTALL_DIR/$GOVERSION # GOROOT 设置
export GOPATH=$WORKSPACE/golang # GOPATH 设置
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH # 将 Go 语言自带的和通过 go install 安装的二进制文件加入到 PATH 路径中
export GO111MODULE="on" # 开启 Go moudles 特性
export GOPROXY=https://goproxy.cn,direct # 安装 Go 模块时，代理服务器设置
export GOPRIVATE=
export GOSUMDB=off # 关闭校验 Go 依赖包的哈希值
EOF
```


### `neovim`
```bash
tar xzvf nvim-linux-x86_64.tar.gz
cp bin/nvim /usr/bin/nvim
cp -rf lib/* /usr/lib/
cp -rf share/* /usr/share/

rm -rf ~/.cache/nvim ~/.local/share/nvim/ ~/.config/nvim
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1

# go # https://github.com/golang/tools/tree/master/gopls#support-policy
go install golang.org/x/tools/gopls@v0.11.0
# nodejs > 18
wget https://nodejs.org/dist/v18.13.0/node-v18.13.0-linux-x64.tar.xz
xz -d node-v18.13.0-linux-x64.tar.xz
tar -xvf node-v18.13.0-linux-x64.tar
sudo mv node-v18.13.0-linux-x64 /usr/local/
sudo ln -s /usr/local/node-v18.13.0-linux-x64/bin/npm /usr/local/bin/npm
sudo ln -s /usr/local/node-v18.13.0-linux-x64/bin/node /usr/local/bin/node
npm install -g yarn

# python10
sudo yum install -y gcc openssl-devel bzip2-devel libffi-devel zlib-devel
curl -O https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz
tar -xvf Python-3.10.0.tgz
cd Python-3.10.0
./configure --enable-optimizations
make -j 4  # 根据你的服务器核心数调整并发编译的数量
sudo make altinstall #使用 altinstall 而不是 install，是为了避免覆盖系统自带的 Python 版本。
python3.10 -m pip install --user pynvim
```

### `fzf`