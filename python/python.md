# `abc`
抽象基类，想使用抽象类可以继承它。
抽象类，自己无法实例化，等别人来继承

```python
from abc import ABC, abstractmethod

class MyABC(ABC):
    @abstractmethod
    def task(self):
        pass
```