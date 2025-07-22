# `pip`
### `requirement.txt`
```text
flask==0.12.1
```
锁定版本依赖，但是因为 `flask` 本身也有依赖关系，但是它不为依赖项指定版本，因此应用程序可以引入一个致命错误。
使用 `requirement.txt` 并不能稳定的构建相同的环境，解决这个办法的方式是使用 `pip freeze` 来冻结环境
目前环境已经被冻结，如果想要更新某一项特定的版本的时候就需要手动维护配置文件。

##### 解决依赖关系
```text
package_a # 依赖 package_c > 10
package_b # 依赖 package_c < 20

package_c>10, <=20
```
最理想的情况是软件自动寻找符合这些要求的版本，但是 `pip` 本身没有这个功能，因此需要添加子依赖项目来解决这个问题

# `pdm`

##### 节约空间
如果存在多个项目使用虚拟环境，其中可能存在着大量相同版本的依赖，我看可以通过 `cache` 的机制，把真正的库安装到中央的某个共享位置，通过符号链接将项目链接过来

### 使用
1. `pdm init`
2. 选择 python 版本 
3. 是否安装虚拟环境 
4. 项目是否会发布出去 
5. 设置 `requires-python`
   - `=3.7`
     - `5.7` 及其以上版本
   - `=3.7, <3.11`
     - `3.7; 3.8; 3.9; 3.10`
   - `=3.6, !=3.8, !=3.9`
     - `3.6` 及以上不含 `3.8; 3.9`
> 如果项目需要构建，安装，需要保证构建的后端支持 `python` 版本

### 迁移其他包管理器的项目
在执行 `pdm init; pdn install`，可能会自动检测可能要导入的文件

### 迁移其他包管理器的项目
在执行 `pdm init; pdn install`，可能会自动检测可能要导入的文件

### `Git`
1. `pyproject.toml`
   - 包含 `pdm` 需要的项目构建元数据和依赖项目
2. `pdm.lock`
   - 版本控制
3. `pdm.toml`
   - 项目范围配置
4. `.pdm-python`
   - 当前项目 `python`路径，不需要上传

### 常用命令
- `pdm info`
- `pdm add`
  ```text
    pdm add requests
    pdm add requests=2.1.0 # 指定版本
    pdm add requests[socks] # 添加具有额外依赖性的请求
    pdm add "flask>=1.0" flask-sqlalchemy # 添加多个依赖项
  
    pdm add ./requests # 使用路径添加本地包
    pdm add "https://github.com/numpy/numpy/releases/download/v1.20.0/numpy-1.20.0.tar.gz" # 使用 `URL` 依赖项目
    
    pdm add "git+https://github.com/pypa/pip.git@22.0" # 版本控制系统依赖项目；`{vcs}+{url}@{rev}`; `vcs`: `git`, `hg`, `svn`, `bzr`
  
    [project]
    dependencies = [
    "mypackage @ git+http://${VCS_USER}:${VCS_PASSWD}@test.git.com/test/mypackage.git@master" # ${ENV_VAR} 使用环境变量隐藏凭证
    ]
  ```
- `-G/-group <name>`
  - 创建额外的依赖组
  - `pdm add -dG test pytest`
    - 进用来测试，发布时候不添加进去
    ```text
    参数使用 `-d` 或者 `-dev`
    [tool.pdm.dev-dependencies]
    test = ["pytest"]
    ```
- `pdm add -e ./sub-package --dev`'
  - 以可编辑模式安装，但是仅允许安装到开发组里面
- `pdm update`
  - 更新
- `pdm remove`
  - 移除
- `pdm sync`
  - 从锁定文件安装软件包
- `pdm install`
  - 检查文件是否更改，如果有必要将会更新锁定文件
- `-L/ -- lockfile`
  - 指定锁定文件
- `pdm export -o requirements.txt`
  - 将锁定文件导出为其他格式

### 设置中央缓存
- `pdm config install.cache on`
  - 启动中央缓存设置

### 配置脚本
- `pdm run flask run -p 12`
  - 在当前项目环境中运行 `flask run -p 12`
```text
[tool.pdm.scripts]
start = "flask run -p 54321"

start = {[cmd/shell/call/composite] = [
    "flask",
    "run",
    # Important comment here about always using port 54321
    "-p", "54321"
]}

foobar = {call = "foo_package.bar_module:main('dev')"}

lint = "flake8"
test = "pytest"
all = {composite = ["lint", "test"]}

start.cmd = "flask run -p 54321"
start.env = {FOO = "bar", FLASK_ENV = "development"} # 配置环境变量
start.env_file = ".env" # 指定环境变量文件

_.env_file = ".env" # `_` 可以被其他任务共享

cmd = "echo '--before {args} --after'" # 占位符

whoami = { shell = "echo \`{pdm} -V\` was called as '{pdm} -V'" } # {pdm} 应对多个 `pdm` 安装的情况

pdm run  start
```
