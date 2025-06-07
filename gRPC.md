# `gRPC`

客户端在不知道调用细节的情况下，调用存在远程计算机上的对象。跨平台跨语言。

组成
- 客户端
- 客户端存根
  - 存储要调用的服务器地址
  - 将数据打包发送给服务器存根
  - 接受结果数据
- 服务器
- 服务器存根
  - 接受客户端存根请求数据
  - 调用服务端服务
  - 返回结果给客户端存根

### 远程调用中带来的新的问题

- `Call id` 的映射
- 序列化和反序列化
- 网络传输


### `Protocol Buffers`

- `proto` 文件中定义要序列化的数据结构，`.proto` 结尾的文本文件. 数据被构造为消息，每一个消息都是小的逻辑记录，其中是使用键值对

  ```protobuf
  message Person {
  	string name = 1;
  	int32 id = 2;
  	bool has_ponycopter = 3;
  }
  ```

- 可以扩展新信息，而不会使现有代码失效或者强行更新代码；广泛应用于服务器通讯和磁盘数据归档

- 编译器调用

    - `--python_out=`输出目录，为每个`.proto` 文件创建一个 `_pb2.py` 文件其中

    - `--pyi_out` 参数生成 `python` 存根 `.pyi`

      > 进行静态检查驱动

    - 编译器会自动创建子目录

    - 如果出现了不能被 `python` 使用的字符，它们将会被替换成为下划线

### 类型

##### `Any`

可以调用 `Pack()` 将指定的消息打包到当前的 `Any` 消息中，或者调用 `unpack` 将消息解包

`Is()` 用来检查 `Any` 消息是否为给定的协议缓冲区类型 ; `TypeName()` 用来检索内部消息类型名称

```protobuf
assert any_message.Is(message.DECRIPTOR)
```

##### `Timestamp` 或者`Duration`

##### `FieldMask`

- 检查消息有效性
- 获取所有字段
- ...

##### `Struct`

允许直接获取和设置项目

```protobuf
struct_message["key1"] = 5
    struct.get_or_create_struct("key4")["subkey"] = 11.0
```

##### `ListValue`

类似 `Python` 消息序列

```
list_value = struct_message.get_or_create_list("key")
list_value.extend([6, "seven", True, None])
list_value.append(False)
```

##### 单数字段

对应的类都有一个与其名称相同的属性；默认包含一些整数常量，包含字段编号，后面跟 `_FILED_NUMBER`

```
optional int32 foo_bar = 5;			FOO_BAR_FIELD_NUMBER = 5
```

如果字段名称为 `Python` 关键字，则只能通过 `getattr()` 和 `setattr` 访问其属性

##### 单数消息字段

不能嵌入式消息字段赋值，但是可以为字段直接赋值

```protobuf
message Foo {
  optional Bar bar = 1;
}

message Bar {
  optional int32 i = 1;
}

    foo = Foo()
    foo.bar = Bar()            # WRONG


    foo = Foo()
    assert not foo.HasField("bar")
    foo.bar.i = 1
    assert foo.HasField("bar")
assert foo.bar.i = = 1
    foo.ClearField("bar")
    assert not foo.HasField("bar")
    assert foo.bar.i = = 0
```

##### 重复字段

标量，枚举和消息

类似于序列的对象，无法直接分配内存但是可以直接对其进行操作

##### 非重复字段

`Map` 和 `oneof`

##### 重复消息

类似于重复标量字段，其中 `add()` 方法创建一个新的消息对象，并将其附加到列表中；重复消息不支持项赋值

##### `Map`

类似于字典，消息无法直接分配 `map` 值

##### 引用未定义的键

如果引用的键不存在，会给予默认值类似于 `python` 标准库 `defaultdict`

##### `Oneof`

只允许设置 `name` 或者 `serial_number` 中的一个

##### 关键字冲突

如果名字发生冲突就只能使用 `getattr()` 和 `setattr()` 内置函数来访问



