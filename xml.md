# XML

### 简介

可扩展标记语言，主要用来传输数据。标签没有预定义，需要自己设计具有自我描述性

语法

- 必须有根元素
- 元素
    - 开始标签
    - 结束标签
    - 元素内容
    - 文本
    - 属性（尽量不使用）
        - 不能包含多个值
        - 不能包含树结构
        - 不容易扩展
    - 其他元素
- 单标签
    - 同时包含开始和结束两个元素
- 标签对大小写敏感
- 必须正确嵌套
- 属性值必须加引号
- 特殊字符需要使用实体引用
- 空格会被保留
- 元素命名规则
    - 可以包含字母数字已经其他字符
    - 不能以数字字母开头
    - 不能以 `xml` 开头
    - 名称不能包含空格

```python
def encode_char(string, char):
    repl_map = {
        ">": "__&gt;__",
        "<": "__&lt;__",
        " ": "__&nbsp;__",
        "&": "__&amp;__",
    }
    for i in char:
        if i in repl_map.keys():
            string = string.replace(i, repl_map[i]) if i in string else string
    return string
```

### `xml` 标准库

相对于第三方 `lxml`，不需要安装但是性能没有它好

`xml.etree.ElementTree` 是主要解析功能

- `ElementTree`
    - 整个文档
- `Element`
    - 文档中的节点
    - 通过列表接口可以访问子节点
    - 通过字典接口可以访问属性值
    - 通过方法可以调用 `XPath` 语法
        - `findall(path)`
        - `find(path)`
- `XPath` 语法
    - `tag`
        - 匹配特定标签
    - `*`
        - 匹配所有元素
    - `.`
        - 当前节点, 用于相对路径
    - `...`
        - 父节点
    - `[@attrib]`
        - 匹配包含 attrib 属性的节点
    - `[@attrib='value']`
    - `[tag]`
        - 匹配包含直接子节点 `tag` 的节点
    - `[tag='text']`
    - `[n]`
        - 匹配第 n 个节点

```python

import xml.etree.ElementTree as ET

tree = ET.parse("./book.xml")
tree = ET.fromstringlist(lines)
root = tree.getroot()
```