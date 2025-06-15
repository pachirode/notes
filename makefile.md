# `Makefile`

一个工程文件的编译规则，描述整个工程文件的编译和链接；实际使用过程中一般是先编写 `Makefile`
文件，告诉整个项目的编译规则，然后通过 `make` 命令来执行编译规则，生成最终的可执行文件。

- 哪些源文件需要被编译
- 需要创建那些库以及如何创建
- 如何最终生成我们想要的可执行文件

### 组成

- 一系列规则指定源文件编译的先后顺序
    - 目标
    - 依赖
    - 命令
- 特定语法规则
    - 变量
    - 函数
    - 函数调用
- 操作系统的各种命令
    - `shell` 脚本

#### 规则

- `target`
    - 目标文件
    - 可执行文件
    - 标签
    - 多个目标时，目标中间使用空格分隔
- `prerequisites`
    - 生成该目标需要的依赖项，多个依赖项之间使用空格分隔
- `command`
    - 目标需要执行的命令
    - 执行之前会默认打印命令
    - 多条命令分行
    - 命令有前后依赖关系，写在一行使用 `;` 分隔
    - 在命令前添加 `-` 表示忽略错误
- 规则中可以使用通配符
    - `*`
    - `?`
    - `~`

```makefile
target ...: prerequisites ...
	command
	    ...
	    ...
```

```c
#include <stdio.h>
int main()
{
  printf("Hello World!\n");
  return 0;
}
```

```makefile
hello: hello.o
	gcc -o hello hello.o
			    
hello.o: hello.c
	gcc -c hello.c
			    
clean:
	rm hello.o
```

```bash
make # 产生可执行文，文件都存在不执行
make clean # 用来清理编译中间产物，或者定制清理
```

##### 伪目标

管理功能主要是通过伪目标来实现的，要执行的功能在 `Makefile` 里面以伪目标的形式存在
我们不会为伪目标生成文件，因此伪目标总是会执行

```makefile
.PHONY: clean # .PHONY 表示这是一个伪目标
clean:
    rm hello.o
    
.PHONY: all
all: lint test build # 伪目标可以依赖文件
```

##### `order-only` 依赖

当 `prerequisites` 中的部分文件改变时才重新构造

```makefile
targets : normal-prerequisites | order-only-prerequisites # 只有第一版构建的时候会使用 order-only-prerequisites
    command
```

##### 导入其他 `Makefile`

使用 `include` 关键字引入其他 `Makefile`，被包含的文件会插入到当前位置

- 绝对/相对路径，直接根据路径导入
    - 可以使用通配符
- `make` 命令使用参数 `-I` 或者 `--include-dir`，去指定目录下查找
- 如果目录 `<prefix>/include` 存在的话也会去找

```makefile
include <filename>
```

#### 语法

- 命令
    - 支持 `linux` 命令
    - 默认情况下，每条命令执行完 `make` 就会检查返回值，如果返回值不为 `0`，则 `make` 停止执行；命令前添加 `-` 表示忽略错误
- 变量赋值
    - 基本赋值
        - `A = b`
    - 直接赋值
        - `A := b`
    - 未赋值则赋值
        - `A ?= b`
    - 追加
        - `A += b`
    - 多行变量
        - `define Op ...\n...\n endef`
    - 环境变量
        - 预定义环境变量
        - 自定义环境变量
            - 可以覆盖预定义环境变量
        - `export USAGE_OPTIONS`
    - 内置变量
    - 自动化变量
- 引用
    - `$(a)`
    - `${a}`
    - 变量取值为最终赋值

##### 预定义函数

| 函数名                               | 功能描述                                                                                                                                                                               |
|:----------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| $(origin <variable>)              | 有如下返回值：1. undefined：从来没有定义过 2. default：是一个默认的定义 3. environment： 环境变量 4. file：这个变量被定义在 Makefile 中 3. line：这个变量是被命令行定义的 4. override：是被 override 指示符重新定义的 5. automatic：是一个命令运行中的自动化变量 |
| $(addsuffix <suffix>,<names...>)  | 把后缀<suffix>加到<names>中的每个单词后面，并返回加过后缀的文件名序列                                                                                                                                         |
| $(addprefix <prefix>,<names...>)  | 把前缀<prefix>加到<names>中的每个单词后面，并返回加过前缀的文件名序列                                                                                                                                         |
| $(wildcard <pattern>)             | 获取与指定模式匹配的文件列表                                                                                                                                                                     |
| $(word <n>,<text>)                | 取字符串<text>中第<n>个单词（从一开始），并返回字符串<text>中第<n>个单词;如 <n>比<text>中的单词数要大，那么返回空字符串                                                                                                         |
| $(subst <from>,<to>,<text>)       | 把字串 <text> 中的 <from> 字符串替换成 <to>，并返回被替换后的字符串                                                                                                                                       |
| $(eval <text>)                    | 将<text>的内容将作为makefile的一部分而被make解析和执行                                                                                                                                               |
| $(firstword <text>)               | 取字符串 <text> 中的第一个单词，并返回字符串 <text> 的第一个单词                                                                                                                                           |
| $(lastword <text>)                | 取字符串 <text> 中的最后一个单词，并返回字符串 <text> 的最后一个单词                                                                                                                                         |
| $(abspath <text>)                 | 将<text>中的各路径转换成绝对路径，并将转换后的结果返回                                                                                                                                                     |
| $(shell cat foo)                  | 执行操作系统命令，并返回操作结果                                                                                                                                                                   |
| $(info <text ...>)                | 输出一段信息                                                                                                                                                                             |
| $(warning <text ...>)             | 出一段警告信息，而 make 继续执行                                                                                                                                                                |
| $(error <text ...>)               | 产生一个致命的错误，<text ...> 是错误信息                                                                                                                                                         |
| $(filter <pattern...>,<text>)     | 以<pattern>模式过滤<text>字符串中的单词，保留符合模式<pattern>的单词。可以有多个模式。返回符合模式<pattern>的字串                                                                                                          |
| $(filter-out <pattern...>,<text>) | 以<pattern>模式过滤<text>字符串中的单词，去除符合模式<pattern>的单词。可以有多个模式，并返回不符合模式<pattern>的字串                                                                                                        |
| $(dir <names...>)                 | 从文件名序列 <names> 中取出目录部分。目录部分是指最后一个反斜杠（/ ）之前的部分;如果没有反斜杠，那么返回 ./                                                                                                                      |
| $(notdir <names...>)              | 从文件名序列<names>中取出非目录部分。非目录部分是指最後一个反斜杠（/）之后的部分;返回文件名序列<names>的非目录部分。                                                                                                                 |
| $(strip <string>)                 | 去掉<string>字串中开头和结尾的空字符，并返回去掉空格后的字符串                                                                                                                                                |
| $(suffix <names...>)              | 从文件名序列<names>中取出各个文件名的后缀。返回文件名序列<names>的后缀序列，如果文件没有后缀，则返回空字串                                                                                                                       |
| $(foreach <var>,<list>,<text>)    | 把参数<list>中的单词逐一取出放到参数<var>所指定的变量中，然后再执行<text>所包含的表达式。每一次 <text>会返回一个字符串，循环过程中<text>的所返回的每个字符串会以空格分隔，最后当整个循环结束时，<text>所返回的每个字符串所组成的整个字符串（以空格分隔）将会是foreach函数的返回值。                    |