# Django

##### 设计 `model`
使用 `Django` 可以不需要数据库，其附带了一个 `ORM`，可以使用 `python` 代码来描述数据库设计
```python
from django.db import models


class Reporter(models.Model):
    full_name = models.CharField(max_length=70)

    def __str__(self):
        return self.full_name


class Article(models.Model):
    pub_date = models.DateField()
    headline = models.CharField(max_length=200)
    content = models.TextField()
    reporter = models.ForeignKey(Reporter, on_delete=models.CASCADE)

    def __str__(self):
        return self.headline
```
> `python manage.py migrate`    创建数据库

##### 使用 `API`
```python
from django.db import models


class Reporter(models.Model):
    full_name = models.CharField(max_length=70)

    def __str__(self):
        return self.full_name


if __name__ == '__main__':
    Reporter.objects.all()
```

##### 后台管理界面
只要创建好 `model`, 会生成一个专业的，用于生产的管理界面
```python
from django.db import models

class Article(models.Model):
    pub_date = models.DateField()
    headline = models.CharField(max_length=200)
    content = models.TextField()

# admin.py
from django.contrib import admin

from . import models
admin.site.register(models.Article)
```

##### 设计路由
通过 `URLconf` 来设计的。
```python
from django.conf.urls import url
import views

urlpatterns = [
    url(r'^articles/([0-9]{4})/$', views.year_archive),
]
```

##### 编写视图
返回请求页面数据或者抛出异常

##### 设计模板
`setting.py` 文件，可以指定路径列表

### 创建项目
```bash
django-admin startproject mysite
python manage.py runserver  # 启动服务
python manage.py startapp polls # 创建应用
```
- `mysite`
  - `manage.py`   # 命令行工具
  - `mysite`
    - `__init__.py`
    - `settings.py` # 项目配置文件
    - `urls.py`
    - `wsgi.py` # 用于项目与 `WSGI` 兼容的 `Web` 服务器入口
- `polls`
  - `__init__.py`
  - `admin.py`
  - `apps.py`
  - `migrations`
    - `__init__.py`
  - `models.py`
  - `tests.py`
  - `views.py`

##### 路由 
`include` 相当于二级路由，将前面的正则表达删除，剩下的字符串传递给下一级路由判断；二级路由可以随便编写
`url(regex, view, kwargs=None, name=None)`
- `regex` 正则表达式通用缩写
- `view` 正则表达式捕获到的值作为第二个参数

### 数据库
默认数据库为 `SQLite`
在 `setting.py` 中 `INSTALLED_APPS` 可以配置默认应用，这其中某些应用需要配置数据库才能使用
> 可以对 `INSTALLED_APPS` 注释或者删除，数据库迁移就不会涉及到这几个应用

##### 模型
定义模型本质上是定义模型所对应的数据库设计及附带的元数据
激活模型首先需要在 `INSTALLED_APPS` 中添加此应用，然后迁移数据库
```python
INSTALLED_APPS = [
    'polls.apps.PollsConfig',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]
```
迁移是 `Django` 存储模型的变化，可以修改迁移文件
```bash
python manage.py sqlmigrate polls 0001 # 查看 SQL
python manage.py check # 检查项目问题，而不进行迁移或接触数据库
```
> 查看迁移 `SQL` 语句
> 主键 `id` 是自动添加；外键会在字段后面添加 `_id` 
`migrate` 命令用来找出所有没有被应用的迁移文件（`django_migrations` 表来追踪）
> 模型类中添加 `__str__`，方便处理交互提示，同时自动生成的管理界面中也可以使用

```python
from django.db import models


class Question(models.Model):
    def was_published_recently(self):   # 给模型添加自定义方法
        pass

```

##### 交互式
`python manage.py shell`

##### 管理站点
框架提供自动创建模型的管理界面
```bash
python manage.py createsuperuser
python manage.py runserver
```
显示的表单是根据 `Question` 模型文件自动生成的
模型中的不同类型的字段 （DataTimeFiled, CharField），会有对应的输入控件

### 视图
视图是 `Django` 中的一类网页，它通常使用一个特定的函数提供服务
- 博客首页
- 详情页面
- 基于年份归档
- 基于月份归档
- 基于日期归档
- 评论
网页的页面和其他的内容都是由视图来传递的，每个视图都是由一个函数（或者基于类的方法来表示）

视图必须要实现两个功能：返回一个包含被请求页面的 `HttpResponse` 对象，或者抛出异常
> 视图可以使用模板

##### 通用视图
视图虽然可以使用模板注入，但是为了减少代码，可以进行代码优化
1. 转换 `URLconf`
2. 删除旧的，不需要的视图
3. 基于 Django 的通用视图导入新视图

### 静态文件
- 创建一个名为 `static` 的目录
- `STATICFILES_FINDERS` 设置了一系列的查找器

### 后台表单
```python
from django.contrib import admin

from .models import Question


class QuestionAdmin(admin.ModelAdmin):
  fields = ["pub_date", "question_text"]


class QuestionAdmin(admin.ModelAdmin): # 分为多个字段集
  fieldsets = [
    (None, {"fields": ["question_text"]}),
    ("Date information", {"fields": ["pub_date"]}),
  ]


admin.site.register(Question, QuestionAdmin)  # 将模型后台类作为第二个参数传递过去
```

##### 添加关联的对象
```python
class QuestionAdmin(admin.ModelAdmin):
  fieldsets = [
    (None, {"fields": ["question_text"]}),
    ("Date information", {"fields": ["pub_date"], "classes": ["collapse"]}),
  ]
  inlines = [ChoiceInline]
  list_display = ("question_text", "pub_date", "was_published_recently")
  list_filter = ["pub_date"]
  search_fields = ["question_text"]
```

### 调试工具
`python -m pip install django-debug-toolbar`

### 复用性
可以在 `Django Package` 中查找已发布的可重用项目
`setuptools` 来构建包
1. 创建一个新的文件夹来存放应用
2. 编辑 `apps.py`
    ```python
    from django.apps import AppConfig


    class PollsConfig(AppConfig):
        default_auto_field = "django.db.models.BigAutoField"
        name = "django_polls" # name 指向新的模块名称
        label = "polls"
    ```
3. `README.rst`
4. 授权协议
5. `pyproject.toml`
    ```tol
    [build-system]
    requires = ["setuptools>=61.0"]
    build-backend = "setuptools.build_meta"

    [project]
    name = "django-polls"
    version = "0.1"
    dependencies = [
    "django>=X.Y",  # Replace "X.Y" as appropriate
    ]
    description = "A Django app to conduct web-based polls."
    readme = "README.rst"
    requires-python = ">= 3.10"
    authors = [
    {name = "Your Name", email = "yourname@example.com"},
    ]
    classifiers = [
    "Environment :: Web Environment",
    "Framework :: Django",
    "Framework :: Django :: X.Y",  # Replace "X.Y" as appropriate
    "Intended Audience :: Developers",
    "License :: OSI Approved :: BSD License",
    "Operating System :: OS Independent",
    "Programming Language :: Python",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3 :: Only",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
    "Programming Language :: Python :: 3.13",
    "Topic :: Internet :: WWW/HTTP",
    "Topic :: Internet :: WWW/HTTP :: Dynamic Content",
    ]

    [project.urls]
    Homepage = "https://www.example.com/"
    ```
6. `MANIFEST.in` 包含模板和静态文件
7. `python -m pip install build` & `python -m build`
8. `python -m pip install --user django-polls/dist/django-polls-0.1.tar.gz`
```python

INSTALLED_APPS = [
    "django_polls.apps.PollsConfig",
    ...,
]

urlpatterns = [
    path("polls/", include("django_polls.urls")),
    ...,
]
```