# Parsing

提供一系列的类可以使用单独的表达式元素来构建解析器，表达式使用直觉的符号组合。

```python
import re
from pyparsing import Word, Combine, nums

data = [
    "192.168.1.1-(555)123-4567",
    "10.0.0.5-(555)987-6543",
    "172.16.254.1-(555)234-5678",
]

pattern = r'(\(\d{3}\)\d{3}-\d{4})'
pattern1 = r'(\d{1,3}(?:\.\d{1,3}){3})'

for line in data:
    match = re.search(pattern, line)
    if match:
        phone_number = match.group(1)
        print(f"Phone Number: {phone_number}")
    else:
        print("No match found.")

    match = re.search(pattern1, line)
    if match:
        ip_address = match.group(1)
        print(f"IP Address: {ip_address}")
    else:
        print("No match found.")

ipField = Word(nums, max=3)
ipAddr = Combine(ipField + "." + ipField + "." + ipField + "." + ipField)
phoneNum = Combine("(" + Word(nums, exact=3) + ")" + Word(nums, exact=3) + "-" + Word(nums, exact=4))
userdata = ipAddr + "-" + phoneNum
for line in data:
    match = userdata.searchString(line)
    if match:
        ip_address = match[0][0]
        phone_number = match[0][2]
        print(f"IP Address: {ip_address}, Phone Number: {phone_number}")
    else:
        print("No match found.")
```

### 语法
- `Word`
  - 解析变量
    - `Word(alphas, alpanums+'_')`
  - 解析常数
    - `Word(num+'.')`
- 语句
  - 赋值语句
    - `assignmentExpr = identifier + "=" +(identifier|number)`
- 无视两个要素之间的，同时也可以跳过注释
- `stringEnd`
  - 添加到解析最后，确保可以解析到文件结尾

### 语法解析输入文本
- `parseString`
  - 应用语法到给定输入文本（这个文本可以应用多次规则也只会匹配到第一次）
- `scanString`
  - 生成器函数，给定文本和上下界，会尽量返回所有解析的结果
- `searchString`
  - `scanString` 的简单实现，返回一个列表
- `transformString`
  - `scanString` 的实现，附带替换操作
- `delimitedList`
- 大量的 `pyparsing` 属性设置方法会返回调用对象本身
  ```python
  integer = Word(nums)
  integer.Name = "integer"
  integer.ParseAction = lambda t: int(t[0])
  
  integer = Word(nums).setName("integer").setParseAction(lambda t:int(t[0]))
  ```
- 跳过注释
  ```python
  cFunction = Word(alphas)+ "(" + Group( Optional(delimitedList(Word(nums)|Word(alphas))) ) + ")"
  cFunction.ignore( cStyleComment )
  ```


```python

from pyparsing import Word, nums, alphas, alphanums

identifier = Word(alphas, alphanums + '_')
number = Word(nums + '.')

assignmentExpr = identifier + "=" + (identifier | number)
assignmentTokens = assignmentExpr.parseString("pi=3.14159")
print(assignmentTokens)
# ['pi','=','3.14159']
```

### 处理返回值
- `parseString` 返回一个 `ParseResults` 对象
- 打印的结果类似 `python` 列表
- 也支持解析文本中单个部分，需要提前为返回值设置名字
```python
assignmentExpr = identifier.setResultsName("lhs") + "=" + \
(identifier | number).setResultsName("rhs")
assignmentTokens = assignmentExpr.parseString( "pi=3.14159" )
print assignmentTokens.rhs
# 3.14159
```

### 解析时进行预处理
`pyparsing` 支持在解析的时候调用回调函数，可以附加一个单独的表达式。解析器会在匹配到对应形式时调用这些函数 `quotedString.setParseAction( lambda t: t[0][1:-1] )` 移除引号

### `BNF`
- `::=`
  - 被定义为
- `+`
  - 一个或者多个
- `*`
  - 零个或者多个
- `[]`
  - 被包围的是可选的
- 连续的项序列表示被匹配的标记必须在序列中出现
- `|`
  - 两个项目之一会被匹配

### 实例

##### 解析 `Hello, world!` 样式
1. 使用 `BNF` 范式来分析文本的抽象模式
    ``` BNF
    greeting ::= salutation comma greetee endpuc
    word ::= 一个或者多个字符的集合，可以包含 ' 或者 .
    salutation ::= word+
    comma ::= ,
    greetee ::= word+
    endpuc ::= ! | ?
    ```
2. 实现解释器 
   ```python
    from pyparsing import Word, OneOrMore, Literal, oneOf, alphas
    word = Word(alphas+"'.")
    salutation = OneOrMore(word)
    comma = Literal(",")
    greetee = OneOrMore(word)
    endpuc = oneOf("! ?")
    greeting = salutation + comma + greetee + endpuc
    ```
3. 给返回结果添加更多结构
    ```python
    from pyparsing import Word, Combine, nums, alphas, alphanums, OneOrMore, Literal, oneOf, Group, Suppress

    word = Word(alphas + "'.")
    salutation = Group(OneOrMore(word))
    comma = Suppress(Literal(",")) # 返回结果时不显示该字符
    greetee = Group(OneOrMore(word))
    endpunc = oneOf("! ?")
    greeting = salutation + comma + greetee + endpunc
    ```
   
##### 解析球队比分
```BNF
game_result ::= data split team_msg split sorce_msg
digit ::= 0 .. 9
alpha ::= a .. z  A .. Z
comma ::= ,
colon ::= :
split ::= |
moth  ::= (alpha +)
data  ::= moth comma digit comma  digit comma digit colon digit
team_msg ::= (alpha +) colon (alpha +) (alpha +) (alpha +) (alpha +)
sorce_msg ::= (alpha +) colon digit - digit
```
```python
from pyparsing import Word, Combine, nums, alphas, alphanums, OneOrMore, Literal, oneOf, Group, Suppress

data = [
    "May 10, 2023, 18:30 | Teams: A vs B | Score:2-1",
    "May 11, 2023, 20:00 | Teams: C vs D | Score:3-3",
    "May 12, 2023, 19:00 | Teams: E vs F | Score:0-4",
]

word = Word(alphas)
number = Word(alphanums).setParseAction(lambda tokens: int(tokens[0]))
comma = Suppress(Literal(","))
split = Suppress(Literal("|"))
date = Group(word + number + comma + number + comma + number + Suppress(":") + number)
date.setResultsName("date")
teams = Suppress(word + ":") + OneOrMore(word)
scores = Combine(word + Suppress(":") + number + Suppress("-") + number).setResultsName("scores")

game_result = date + split + Group(teams).setResultsName("teams") + split + scores

for line in data:
    res = game_result.parseString(line)
    print(res.dump())   # 返回组织化的结构
    print(res.asXML("GAME")) # 产生一个 `XML`

```
