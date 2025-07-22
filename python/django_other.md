# 模型

### `Meta`

```python
class Meta:
    abstract = True  # 抽象模型
```

# `Manager`

一种接口，赋予了 `Django` 操作数据库的能力，每个模型至少拥有一个；默认情况会自动添加 `objects`
的管理器。表达式支持一个可选的参数（`output_field`）用来确定返回字段的类型，只有无法自动确认结果的字段的时候才会去使用

- 修改原始 `QuerySet`
    - `get_queryset()`

```python
from django.db import models


class BlogManager(models.Manager):
    def test_func(self, *args, **kwargs):
        # 执行一些操作
        return


class Blog(models.Model):
    a = models.IntegerField()
    b = models.IntegerField()
    objects = BlogManager()


# cases
from django.db.models import Count, F, Value
from django.db.models.functions import Length, Upper
from django.db.models.lookups import GreaterThan

Blog.objects.filter(a__gte=F('b'))
Blog.objects.annotate(r=F('a') - F('b'))
blog = Blog.objects.create(1, 2)
blog.refresh_from_db()
```

# 查询表达式

- `F()`
    - 模型字段的值，可以引用模型字段的值并对其执行数据操作
    - 覆盖标准 `python` 运算符创建一个封装的 `SQL` 表达式
    - `update()` 一起使用可以用于 `QuerySets`
        - 原本要 `get` 和 `save` 两个步骤
    - 支持数组切片语法
    - 避免竞争条件
        - 数据库来更新值而不是使用实例
    - 赋值在 `Model.save()` 之后持续存在。通过保存模型对象后重新加载来避免这个问题 `refresh_from_db()`
- `Func()`
  - 涉及到 `LOWER` 等数据库函数或者 `SUM` 等集合表达式
  - 创建数据库函数库
- `Aggregate()`
  - 对查询数据进行聚合操作
- `ExpressionWrapper()`
  - 包围另一个表达式，并提供访问属性的功能
  - 在使用描述中不同类型的 `F()` 表达式进行算术运算时，必须使用
- `Subquery()`
  - 添加一个显示子查询
- `Case()`
  - 在提供的 `When()` 对象中的每个 `condition` 按顺序执行，直到执行出一个对的值
- `When()`
  - 用于封装一个条件及结果，便于在条件表达式中使用，结果用 `then` 关键字返回

```python

from django.db.models import Count, F, Value
from django.db.models.functions import Length, Upper
from django.db.models.lookups import GreaterThan


class Blog(models.Model):
    a = models.IntegerField()
    b = models.IntegerField()


# cases

Blog.objects.filter(a__gte=F('b'))
Blog.objects.annotate(r=F('a') - F('b'))
blog = Blog.objects.create(1, 2)
blog.refresh_from_db()

reporter = Reporters.objects.filter(name="Tintin")
reporter.update(stories_filed=F("stories_filed") + 1)

Reporter.objects.update(stories_filed=F("stories_filed") + 1)  # 快速递增

# Func
from django.db.models import F, Func

queryset.annotate(field_lower=Func(F("field"), function="LOWER"))


class Lower(Func):
    function = "LOWER"


queryset.annotate(field_lower=Lower("field"))

Client.objects.annotate(
    discount=Case(
        When(account_type=Client.GOLD, then=Value("5%")),
        When(account_type=Client.PLATINUM, then=Value("10%")),
        default=Value("0%"),
    ),
)

# CASE 根据客户注册日期修改 `accout_type`
Client.objects.update(
    account_type=Case(
        When(registered_on__lte=a_year_ago, then=Value(Client.PLATINUM)),
        When(registered_on__lte=a_month_ago, then=Value(Client.GOLD)),
        default=Value(Client.REGULAR),
    ),
)

# 聚合查询
Client.objects.aggregate(
    regular=Count("pk", filter=Q(account_type=Client.REGULAR)),
    gold=Count("pk", filter=Q(account_type=Client.GOLD)),
    platinum=Count("pk", filter=Q(account_type=Client.PLATINUM)),
)
# {'regular': 2, 'gold': 1, 'platinum': 3}
```

```python
reporter = Reporters.objects.get(name="Tintin")
reporter.stories_filed = F("stories_filed") + 1 # 会被更新两次
reporter.save()

reporter.name = "Tintin Jr."
reporter.save()


```