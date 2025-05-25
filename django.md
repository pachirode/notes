# Django

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

### `MVT` 设计模式

由模型，视图和模板三个部分组成，分别对应单个 `app` 下面 `model.py`,  `views.py`, `templates`
其中最重要的是视图，它同时与模型和模板进行交互

##### 模型

数据模型是 `Django` 应用的核心，其本身不是数据，而是抽象描述数据的构成和逻辑关系
> `python manage.py migrate`    创建数据库
> 设计模型的注意事项

- 字段是否必选
    - `CharFiled` 中的 `max_length` 和 `ForeignKey` 中的 `on_delete` 是必选的
- 字段是否是必需的，是否可以为空

模型组成

- 模型字段
    - 定义模型的字段
        - 基础字段和关系字段
- 自定义的 `Manager` 方法
- `META` 选项
- 方法
    - `def __str__`
    - `def save`
    - `def get_absolute_url`

模型字段

- 基础字段
    - `CharField`
        - 一般需要设置 `max_length`，如果不是必填，`blank=True, default=''`;如果由 `choice=XXX_CHOICE`
    - `TextFiled`
        - 适合大量文本
    - `DataField` `DateTimeField`
        - `auto_now=True` 自动记录修改的日期
        - `auto_now_add=True` 自动记录创建日期
    - `EmailField`
    - `FileField`
        - `upload_to` 上传文件夹路径
    - `ImageFiled`
- 关系字段
    - `OneToOneField(to, on_delete=xxx, options)`
        - `to` 必需指向其他模型
        - 必须指定 `on_delete` 选项
        - `related_name` 可以设置用来反向查询
    - `ForeginKey(to, on_delete=xxx, options)`
        - `to` 必需指向其他模型
        - 必须指定 `on_delete` 选项
        - 可以使用 `default` `null=True`
        - `related_name` 可以设置用来反向查询
    - `ManyToManyField(to, through=None, options)`
        - `to` 必需指向其他模型
        - `symmetrical = False` 表示多对多关系不对称
        - `through = 'intermediary model'` 需要建立中间模型来获取更多数据
        - `related_name` 可以设置用来反向查询
- 选项
    - `on_delete`
        - `CASCADE` 级联删除
        - `PROTECT` 保护模式，如果有外键关联就不允许删除
        - `SET_NULL` 外键删除质控
        - `SET_DEFAULT` 删除时设置为默认值
        - `SET()` 自定义一个值
        - `DO_NOTHING` 什么都不做，删除之后无法使用外键进行查询
    - `related_name`
        - 设置模型反向查询的名字

`META`

- `abstract=True` 指定模型为抽象模型
- `proxy=True` 指定模型为代理模型
- `verbose_name` `verbose_name_plural` 为模型设置便于人类阅读的别名
- `db_table` 自定义数据表名字
- `ordering=['data']` 自定义按照字段排序
- `permissions=[]` 定义该模型的权限
- `manage=False` 不为这个模型生成数据表
- `indexs=[]` 为数据库设置索引
- `constraints=` 给数据库中的数据表添加约束

模型方法

- `__str__`
    - 给单个模型对象实例设置文本
- `save()`
- `get_absolute_url()`
    - 为实例生成一个指向该对象的 URL

```python
from django.db import models
from django.urls import reverse


# 自定义Manager方法
class HighRatingManager(models.Manager):
    def get_queryset(self):
        return super().get_queryset().filter(rating=1)


# CHOICES选项
class Rating(models.IntegerChoices):
    VERYGOOD = 1, 'Very Good'
    GOOD = 2, 'Good'
    BAD = 3, 'Bad'


class Product(models.Model):
    # 数据表字段
    name = models.CharField('name', max_length=30)
    rating = models.IntegerField(max_length=1, choices=Rating.choices)

    # MANAGERS方法
    objects = models.Manager()
    high_rating_products = HighRatingManager()

    # META类选项
    class Meta:
        verbose_name = 'product'
        verbose_name_plural = 'products'

    # __str__方法
    def __str__(self):
        return self.name

    # 重写save方法
    def save(self, *args, **kwargs):
        self.do_something()
        super().save(*args, **kwargs)
        self.do_something()

    # 定义单个对象绝对路径
    def get_absolute_url(self):
        return reverse('product_details', kwargs={'pk': self.id})

    # 其它自定义方法
    def do_something(self):
        pass
```

##### `ORM` 模型

无需使用 `SQL` 语句可以通过对模型的简单操作实现对数据库里面的数据操作

- 增
    - `save`
    - `create`
        - `get_or_create` 防止创建重复数据
        - `create_user` 操作 `Django` 自带的 `auth` 模块
    - `bulk_create` 依次添加多组数据
- 删
    - `delete`
- 改
    - `save`
        - 可以创建新的对象
    - `update`
        - 只能更新现有的对象，可以同时更新多个
    - `bulk_update`
- 查
    - `get`
        - 不存在会报错
        - `get_object_or_404`
    - `filter`
        - 不存在不会报错
    - `exclude`
- 排序
    - `order_by`
- 去重
    - `distinct`
- `Q` 逻辑的条件查询
    - `filter(Q(name='John') | Q(name='Mike'))`
- `F` 基于自身字段来过滤一组对象，同时支持 加减乘除操作
    - `filter(id=F('model_id') * 2)`

##### 路由配置

每个 `app` 下面都有 `urls.py` 文件, `Django` 会根据用户请求 `URL` 地址和 `urls.py` 中的配置的映射关系去调用合适的视图
通过 `url` 将参数传递给视图

- `path`
- `re_path`
- 注意事项
    - 需要传入的参数使用 `<>`
    - 匹配模式建议使用 `/` 结尾
    - `re_path` 不一定总是需要使用 `$` 结尾，如果是加入其他的路由配置就不能使用
- 命名
    - 给 `URL` 定义一个全局变量，方便在其他地方使用，尤其是模板内
- `reverse`
    - 对 `URL` 已经命名的进行反向解析，方便在视图里面使用
- 指向基于类的视图
    - `as_view`, 将一个类伪装成方法
- 通过字典传参

```python
urlpatterns = [
    path('blog/articles/<int:id>/', views.article_detail, name='article_detail'),
    re_path(r'^blog/articles/(?P<id>\d+)/$', views.article_detail, name='article_detail'),
]

# url 是模板标签，作用是对命名的的 `url` 进行解析，动态生成链接
{ %
for article in articles %}
< a
href = "{% url 'article_detail' article.id %}" > {{article.title}} < / a >
{ % endfor %}

reverse('blog:article_detail', args=[id])

path('blog/articles/', views.ArticleList.as_view(), name='article_list')

path('', views.ArticleList.as_view(), name='article_list', {'blog_id': 3}),
```

##### 视图

处理业务逻辑的核心。视图函数的第一个参数必须是 `request`，它是一个全局变量。`Django` 把每个用户请求封装为 `request`
对象，它包含请求的所有信息

- 基于函数的视图
    - 比较直接，但是复用性差
- 基于类的视图
- 通用类视图
    - `ListView`
        - 重写以下方法修改默认内容
            - `queryset`
            - `template_name`
            - `context_object_name`
    - `DetailView`
    - `CreateView`
    - `UpdateView`
    - `FormView`
    - `DeleteView`
  > 使用和修改相关的视图，模型必须定义 `get_absolute_url`

```python
from django.views.generic import View, ListView


class MyClassView(View):
    def get(self, request):
        pass

    def post(self, request):
        pass


class IndexView(ListView):
    model = Article
    queryset = Article.objects.all().order_by('-pub_date')
    template_name = 'blog/article_list.html'
    context_object_name = 'article_list'


def index(request):
    queryset = Article.objects.all()
    return render(request, 'blog/arcticle_list.html', {'article_list': queryset})
```

##### 表单

表单用于让用户提交数据或者上传文件，也可以用来编辑已有的数据。`Django` 的表单作用是把用户输入的数据转换为 `python`
对象格式。一般将表单放在 `forms.py`

自定义表单类

- 继承 `Form`
    - 需要自定义表单中的字段
- 继承 `ModelForm`
    - 可以根据 `Django` 模型自动生成表单

> 可以使用 `label` 来给表单添加一个别名

```python
from django import forms


class ContactForm1(forms.Form):
    name = forms.CharField(label="Your Name",
                           max_length=255,
                           error_messages={  # 自定义错误信息
                               'required': '用户名不能为空',
                               'max_length': '用户名长度不得超过20个字符',
                               'min_length': '用户名长度不得少于6个字符',
                           },
                           widget=forms.Textarea(  # 定义表单输入空间
                               attrs={'class': 'custom'},
                           ),
                           )
    email = forms.EmailField(label="Email address")


class ContactForm2(forms.ModelForm):
    class Meta:
        model = Contact
        fields = ('name', 'email',)
        widgets = {
            'name': Textarea(attrs={'cols': 80, 'rows': 20}),  # 定义错误信息
        }

```

实例化和初始化

- 表单是如何工作的
    - 用户通过 `POST` 方法提交表单，将提交的数据和表单类结合，验证表单
    - 如果表单数据有效，创建模型对象
    - 登陆成功，重定向到新的页面
    - 如果用户没有提交表单或者不是通过 `POST` 方法提交表单
- 表单验证
    - 如果提交的信息未通过验证，会提示用户。通过的数据存储在 `cleaned_data`
    - `clean_字段名` 的方式自定义表单验证
- 通用类视图使用表单
    - 通过 `model + fields` 方式
    - `form_class`
- 一次提交多个表单
    - `Formset`

```python
form = ContactForm()

# 设置初始化信息
form = ContactForm(initial={'name': 'John Doe'})

form = ContactForm(data=request.POST, files=request.FILES)

from django import forms


class RegistrationForm(forms.Form):
    username = forms.CharField(label='Username', max_length=50)
    email = forms.EmailField(label='Email', )
    password1 = forms.CharField(label='Password', widget=forms.PasswordInput)
    password2 = forms.CharField(label='Password Confirmation', widget=forms.PasswordInput)


def register(request):
    if request.method == 'POST':
        form = RegistrationForm(request.POST)
        if form.is_valid():
            username = form.cleaned_data['username']
            email = form.cleaned_data['email']
            password = form.cleaned_data['password2']
            user = User.objects.create_user(username=username, password=password, email=email)
            return HttpResponseRedirect("/accounts/login/")
    else:
        form = RegistrationForm()

    return render(request, 'users/registration.html', {'form': form})


class ArticleCreateView(CreateView):
    model = Article
    fields = ['title', 'body']
    template_name = 'blog/article_form.html'


class ArticleCreateView(CreateView):
    model = Article
    form_class = ArticleForm
    template_name = 'blog/article_form.html'


from django.forms import formset_factory

FormSet = formset_factory(Form, extra=2, max_num=1)
```

> 只能对绑定过数据的表单进行验证

##### 管理后台

- `python manage.py createsuperuser` 创建管理员
- 注册模型
    - `admin.py`, 使用 `admin.site.register` 将需要管理的模型注册进来
- 自定数据表显示
    - 创建一个继承 `admin.ModelAdmin` 的类
    - 外键或者多对多优化
        - `autocomplete_fields` `raw_id_fields`

```python
from django.contrib import admin


class ArticleAdmin(admin.ModelAdmin):
    list_display = ('title', 'author', 'status', 'create_date',)  # 定义显示字段
    list_editable = ('status',)  # 定义可编辑字段
    list_per_page = 5  # 分页
    list_max_show_all = 200  # 最大条目
    search_fields = ['title']  # 页面搜索框
    date_hierarchy = 'create_date'  # 按日期分组
    empty_value_display = 'NA'  # 默认空值


admin.site.register(Article, ArticleAdmin)
```

##### 连接数据库

`Django` 默认使用 `Sqlite` 数据库，它是一种嵌入式数据库。只是一个 `.db`
格式的文件。常用于中小型网站，嵌入式设备和应用软件(`android`)，文档管理和桌面 `.exe`。但是他无法应对高流量和高并发的场景
使用 `mysql`

- `pip install mysqlclient`
- `settings.py`
- `python manage.py makemigrations; python manage.py migrate`
  使用 `PostgreSQL`
- `pip install psycopg2`
-

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql', 'django.db.backends.postgresql_psycopg2'  # 数据库引擎
                                              'NAME': 'mydb',  # 数据库名，Django不会帮你创建，需要自己进入数据库创建。
        'USER': 'myuser',  # 设置的数据库用户名
        'PASSWORD': 'mypass',  # 设置的密码
        'HOST': 'localhost',  # 本地主机或数据库服务器的ip
        'PORT': '3306',  # 数据库使用的端口
    }
}

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'OPTIONS': {
            'read_default_file': '/path/to/my.cnf',
        },
    }
}
# my.cnf
[client]
database = mydb
user = myuser
password = mypass
default - character - set = utf8

```

##### `Cookie` 和 `Session`

`HTTP` 本身是无状态的，因此服务器无法识别来自同一用户的连续请求，因此需要这样的东西来记录客户端的访问状态，来避免重复登陆
`Cookie`
一种数据存储技术，将一段文本保存在客户端（浏览器或本地电脑），可以长期存储。当用户首次登录的时候，服务器会发送给客户端一小段信息。客户端浏览器会将这段信息以 `Cookie`
的形式保存到本地，下次访问的时候再次发送给服务端

- 记录登录信息
- 记录搜索关键字
- 不可靠不安全
    - 用户可以设置不保存 `cookie`
    - 有生命周期
    - 明文发送的容易被攻击
    - 以文件的形式存储，用户可以随意更改
      `Session` 原理和 `Cookie` 存储少量数据或者信息，数据存储在服务器上
- `setting.py` 中开启中间件 `'django.contrib.sessions.middleware.SessionMiddleware'`
- 添加 `app` `'django.contrib.sessions',`

```python
response.set_cookie(cookie_name, value, max_age=None, expires=None)  # 设置cookie
request.COOKIES['username']  # 获取cookie

request.session['key'] = value
request.session.set_expiry(time)
request.session.get('key'，None)
```

##### 分页及通用模板

- 函数视图使用分页
    - `Pagintor(page_obj, is_paginated)`
        - `page_obj`
            - 分页后的对象列表
        - `is_pageinated`
            - 可选，总页数不超过1页时为False，不显示分页
- 类视图使用分页

```python
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger


def article_list(request):
    queryset = Article.objects.filter(status='p').order_by('-pub_date')
    paginator = Paginator(queryset, 10)  # 实例化一个分页对象, 每页显示10个
    page = request.GET.get('page')  # 从URL通过get页码，如?page=3
    try:
        page_obj = paginator.page(page)
    except PageNotAnInteger:
        page_obj = paginator.page(1)  # 如果传入page参数不是整数，默认第一页
    except EmptyPage:
        page_obj = paginator.page(paginator.num_pages)
    is_paginated = True if paginator.num_pages > 1 else False  # 如果页数小于1不使用分页
    context = {'page_obj': page_obj, 'is_paginated': is_paginated}
    return render(request, 'blog/article_list.html', context)


class ArticleListView(ListView):
    queryset = Article.objects.filter(status='p').order_by('-pub_date')
    paginate_by = 10  # 每页10条

# 分页模板
< ul >
{ %
for article in page_obj %}
< li > {{article.title}} < / li >
{ % endfor %}
< / ul >

{ % if is_paginated %}
< div


class ="pagination" >

< span


class ="step-links" >


{ % if page_obj.has_previous %}
< a
href = "?page=1" > & laquo;
first < / a >
< a
href = "?page={{ page_obj.previous_page_number }}" > 上一页 < / a >
{ % endif %}

< span


class ="current" >


Page
{{page_obj.number}}
of
{{page_obj.paginator.num_pages}}.
< / span >

{ % if page_obj.has_next %}
< a
href = "?page={{ page_obj.next_page_number }}" > 下一页 < / a >
< a
href = "?page={{ page_obj.paginator.num_pages }}" > last & raquo; < / a >
{ % endif %}
< / span >
< / div >
{ % endif %}

< link
rel = "stylesheet"
href = "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta/css/bootstrap.min.css"
integrity = "sha384-/Y6pD6FV/Vv2HJnA6t+vslU6fwYXjCFtcEpHbNJ0lyAFsXTsjBbfaDjzALeQsN6M"
crossorigin = "anonymous" >

{ % if page_obj %}
< ul >
{ %
for article in page_obj %}
< li > {{article.title} < / li >
  { % endfor %}
< / ul >

    {  # 分页链接 #}
        { % if is_paginated %}
    < ul


class ="pagination" >


{ % if page_obj.has_previous %}
< li


class ="page-item" > < a class ="page-link" href="?page={{ page_obj.previous_page_number }}" > Previous < / a > < / li >


{ % else %}
< li


class ="page-item disabled" > < span class ="page-link" > Previous < / span > < / li >


{ % endif %}

{ %
for i in page_obj.paginator.page_range %}
{ % if page_obj.number == i %}
< li


class ="page-item active" > < span class ="page-link" > {{i}} < span class ="sr-only" > (current) < / span > < / span > < / li >


{ % else %}
< li


class ="page-item" > < a class ="page-link" href="?page={{ i }}" > {{i}} < / a > < / li >


{ % endif %}
{ % endfor %}

{ % if page_obj.has_next %}
< li


class ="page-item" > < a class ="page-link" href="?page={{ page_obj.next_page_number }}" > Next < / a > < / li >


{ % else %}
< li


class ="page-item disabled" > < span class ="page-link" > Next < / span > < / li >


{ % endif %}
< / ul >
{ % endif %}

{ % else %}
{  # 注释: 这里可以写自己的句子 #}
    { % endif %}
```

##### 上传文件

文件或者图片一般通过表单进行。服务器收到请求之后需要将其存在服务器上。`Django` 默认的存储地址为 `根目录/media/文件夹`
，存储的默认文件名就是文件本来的名字。如果文件超过 `2.5MB`，先存入服务器内存中再写入磁盘。如果文件很大，会将文件写入临时文件，再写入磁盘
默认处理方式会出现问题，所有文件都存储到一个文件夹中，文件可能会相互覆盖
上传方式

- 自定义表单上传
- 用模型创建的表单上传
- 使用 `Ajax` 实现文件异步上传，上传页面无需刷新可以显示新上传的文件

```python
# 设置上传
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
MEDIA_URL = '/media/'


# 创建模型用来管理文件上传
def user_directory_path(instance, filename):
    ext = filename.split('.')[-1]
    filename = '{}.{}'.format(uuid.uuid4().hex[:10], ext)
    return os.path.join("files", filename)


class File(models.Model):
    file = models.FileField(upload_to=user_directory_path, null=True)
    upload_method = models.CharField(max_length=20, verbose_name="Upload Method")


class FileUploadForm(forms.Form):
    file = forms.FileField(widget=forms.ClearableFileInput(attrs={'class': 'form-control'}))
    upload_method = forms.CharField(label="Upload Method", max_length=20,
                                    widget=forms.TextInput(attrs={'class': 'form-control'}))

    def clean_file(self):
        file = self.cleaned_data['file']
        ext = file.name.split('.')[-1].lower()
        if ext not in ["jpg", "pdf", "xlsx"]:
            raise forms.ValidationError("Only jpg, pdf and xlsx files are allowed.")
        # return cleaned data is very important.
        return file


# 方法上传
def file_upload(request):
    if request.method == "POST":
        form = FileUploadForm(request.POST, request.FILES)
        if form.is_valid():
            # get cleaned data
            upload_method = form.cleaned_data.get("upload_method")
            raw_file = form.cleaned_data.get("file")
            new_file = File()
            new_file.file = handle_uploaded_file(raw_file)
            new_file.upload_method = upload_method
            new_file.save()
            return redirect("/file/")
    else:
        form = FileUploadForm()

    return render(request, 'file_upload/upload_form.html',
                  {'form': form, 'heading': 'Upload files with Regular Form'}
                  )


def handle_uploaded_file(file):
    ext = file.name.split('.')[-1]
    file_name = '{}.{}'.format(uuid.uuid4().hex[:10], ext)

    # file path relative to 'media' folder
    file_path = os.path.join('files', file_name)
    absolute_file_path = os.path.join('media', 'files', file_name)

    directory = os.path.dirname(absolute_file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)

    with open(absolute_file_path, 'wb+') as destination:
        for chunk in file.chunks():
            destination.write(chunk)

    return file_path


# 使用模型创建
class FileUploadModelForm(forms.ModelForm):
    class Meta:
        model = File
        fields = ('file', 'upload_method',)
        widgets = {
            'upload_method': forms.TextInput(attrs={'class': 'form-control'}),
            'file': forms.ClearableFileInput(attrs={'class': 'form-control'}),
        }

    def clean_file(self):
        file = self.cleaned_data['file']
        ext = file.name.split('.')[-1].lower()
        if ext not in ["jpg", "pdf", "xlsx"]:
            raise forms.ValidationError("Only jpg, pdf and xlsx files are allowed.")
        # return cleaned data is very important.
        return file


def model_form_upload(request):
    if request.method == "POST":
        form = FileUploadModelForm(request.POST, request.FILES)
        if form.is_valid():
            form.save()  # 一句话足以
            return redirect("/file/")
    else:
        form = FileUploadModelForm()

    return render(request, 'file_upload/upload_form.html',
                  {'form': form, 'heading': 'Upload files with ModelForm'}
                  )
```

##### `Ajax`

前后端交互数据的方式

- `urlencoded`
    - `Ajax` 给后台发送数据的默认编码格式
- `formdata`
- `json`

```js
$("#btnSubmit").click(function () {
    $.ajax({
        url: '/login/',
        type: 'post',
        data: {
            'username': $("#id_username").val(),
            'password': $('#id_password').val()
        },
        // 下面data形参指代的就是异步提交的返回结果data
        success: function (data) {

        }
    });
});


// FormData enctype="multipart/form-data"
$("#submitFile").click(function () {
    let formData = new FormData($("#upload-form"));
    $.ajax({
        url: "/upload/",
        type: "post",
        data: formData,
        //这两个要必须写
        processData: false,  //不预处理数据  因为FormData 已经做了
        contentType: false,  //不指定编码了 因为FormData 已经做了
        success: function (data) {
            console.log(data);
        }
    });
});

// json
$("#submitBtn").click(function () {
    var data_obj = {'name': 'abcdef', 'password': 123456};//Javascript对象
    $.ajax({
        url: '',
        type: 'post',
        contentType: 'application/json',  //一定要指定格式 contentType
        data: JSON.stringify(data_obj),    //转换成json字符串格式
        success: function (data) {
            console.log(data)
        }
    });
});
```

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

### 配置文件

项目的全局默认设置在 `django/conf/global_settings.py`，会优先加载这个配置，然后再载入用户指定的 `setting.py`

- `BASE_DIR`
    - 项目文件夹所在的绝对路径，一般不修改
- `DEBUG`
    - 开发测试环境使用，如果设置为 `False`，一定要设置 `ALLOWED_HOSTS`
- `ALLOWED_HOSTS`
    - 默认为空，如果设置一般是服务器公网 `IP` 或者域名
- `SECRET_KEY`
    - 加密盐，实际生成中不建议直接写字符串明文到 `setting.py`
- `INSTALLED_APPS`
    - 配置了才会生成对应的数据表
- `AUTH_USER_MODEL`
    - 默认 `auth.user` 也可以改为自定义用户模型
- `STATIC_ROOT` `STATIC_URL`
    - 静态文件， `STATIC_URL` 设置之后可以直接通过模板访问静态文件
    - `python manage.py collectstatic` 将每个 `app` 下面的所有名为 `static` 的文件移动到 `STATIC_ROOT` 目录下，方便部署
- `STATICFILES_DIRS`
    - 默认为空，配置的话必须使用绝对路径
    - `python manage.py collectstatic` 收集的时候会把这里面配置的也收集
- `MEDIA_ROOT` `MEDIA_URL`
    - 用来存放用户的上传文件，需要设置文件夹权限
- 模板设置
  ```python
    TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [os.path.join(BASE_DIR, 'templates')], # 设置项目模板目录
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
    ]
  ```
- 中间件设置
    - 在 `MIDDLEWARE` 中注册
- 数据库设置
- 缓存设置
  ```python
    CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://your_host_ip:6379', # redis所在服务器或容器ip地址
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
             "PASSWORD": "your_pwd", # 你设置的密码
        },
    },
    }
  ```

##### 拆解配置

配置文件写在一个大文件下面很难维护，因此我们会将 `setting.py` 拆分为一个 `package`, 将 `setting.py` 移到 `settings`
文件夹下并改为 `base.py`

```python
# settings/__init__.py
from .base import *
```

### `SimpleUI` 使用

```bash
pip install django-simpleui -i https://pypi.tuna.tsinghua.edu.cn/simple
```

```python
INSTALLED_APPS = [
    'simpleui'  # 添加后台模板
]
```

##### 生成环境使用

如果关闭 debug 模式之后，会出现静态资源无法访问；需要克隆静态文件到根目录
`python manage.py collectstatic` 收集静态文件

##### 常用配置

- `LANGUAGE_CODE = 'zh-hans'`
    - 设置语言，默认为 `en-us`
- `SIMPLEUI_LOGO`
    - 修改logo
- 删除推广
    - `SIMPLEUI_HOME_INFO = False`
    - `SIMPLEUI_ANALYSIS = False`
- 修改管理后台名称和标题(`admin.py`)
    - `admin.site.site_header`
    - `admin.site.site_title`
    - `admin.site.index_title`
- 自定义菜单
    - `SIMPLEUI_CONFIG`
        - 定义的菜单不会收到权限控制
    - `SIMPLEUI_ICON`
        - 修改默认菜单图标
- 自定义首页

```python
# app.py 侧边栏改为中文
from django.apps import AppConfig


class TasksConfig(AppConfig):
    name = 'tasks'

    verbose_name = '任务管理'


from third_package.models import ModelA

# 通过打补丁的方式修改其他第三方库
ModelA._meta.verbose_name = ''
ModelA._meta.verbose_name_plural = ''
ModelA._meta.get_field('first_name').verbose_name = '名字'

# setting.py 自定义菜单
SIMPLEUI_CONFIG = {
    # 是否使用系统默认菜单。
    'system_keep': False,

    # 用于菜单排序和过滤, 不填此字段为默认排序和全部显示。 空列表[] 为全部不显示.
    'menu_display': ['任务管理', '权限认证'],

    # 设置是否开启动态菜单, 默认为False. 如果开启, 则会在每次用户登陆时刷新展示菜单内容。
    # 一般建议关闭。
    'dynamic': False,
    'menus': [
        {
            'app': 'auth',
            'name': '权限认证',
            'icon': 'fas fa-user-shield',
            'models': [
                {
                    'name': '用户列表',
                    'icon': 'fa fa-user',
                    'url': 'auth/user/'
                },
                {
                    'name': '用户组',
                    'icon': 'fa fa-th-list',
                    'url': 'auth/group/'
                }
            ]
        },

        {
            'name': '任务管理',
            'icon': 'fa fa-th-list',
            'models': [
                {
                    'name': '任务列表',
                    # 注意url按'/admin/应用名小写/模型名小写/'命名。  
                    'url': '/admin/tasks/task/',
                    'icon': 'fa fa-tasks'
                },
            ]
        },
    ]
}

# 自定义首页
# 隐藏首页
SIMPLEUI_HOME_QUICK = False
SIMPLEUI_HOME_ACTION = False

# 修改左侧菜单首页设置
SIMPLEUI_HOME_PAGE = 'https://www.baidu.com'  # 指向页面
SIMPLEUI_HOME_TITLE = ''  # 首页标题
SIMPLEUI_HOME_ICON = 'fa fa-code'  # 首页图标

# 设置右上角Home图标跳转链接，会以另外一个窗口打开
SIMPLEUI_INDEX = 'https://www.baidu.com'

```

### 查询优化

`QuerySet` 是 `Django` 提供的数据接口，提供了 `filter`, `exclude` 等方法使得我们不用关心原始的 `SQL`
与数据库进行交互。从数据库中查询出来的结果一般是一个集合 `queryset`

##### 惰性

`results = Result.objects.filter(id=1)`，当定义 `results` 的时候，并没有对数据库进行查询，只有当真正需要做进一步运算的时候才会对数据库进行查询

##### 自带缓存

在使用查询结果的时候，这些结果会载入到内存中并保存到 `queryset` 内置的 `cache` 中。`for` 和 `if` 会导致 `queryset` 执行
如果不想触发缓存，使用 `exists`，这个方法只检查结果是否存在

- 统计结果数量
    - `results.count()`
        - 直接从数据库层面统计数量
    - `results.len()`
        - 如果数据集不在缓存中会先触发查询，将结果加载到内存中。如果已经加载到内存，会更快
- 按需提取数据
    - `results.values()`
        - 以字典的形式返回结果
    - `results.values_list()`
        - 以元组的形式返回结果
    - `defer` `only`
    - `iterator`
        - 优化程序对内存的使用

```python
results = Result.objects.filter(id=1)
for result in results:
    print(result)

# 查询结果没有保存到缓存中
for result in Result.objects.filter(id=1):
    print(result)

# 更新操作需要先将对象提取出来，增大内存开销
article = Article.objects.get(id=10)
Article.title = "Django"
article.save()

Article.objects.filter(id=10).update(title='Django')
```

##### `explain`

统计一个查询需要消耗的执行时间

```python
print(Blog.objects.filter(title='My Blog').explain(verbose=True))
```

### 缓存配置

缓存是一类更快读取数据的介质统称，也可以指更快数据读取的存储方式。从数据库中读取数据成本要大一些，使用缓存减少对数据访问的次数可以提高性能
用户的请求到达视图之后，视图会先从数据库读取数据传递给模板渲染，如果用户每次访问都要从数据库中读取数据，增大服务器压力还会导致客户端无法即使获得响应

```python
from django.views.decorators.cache import cache_page


@cache_page(60 * 15)  # 这里指缓存 15 分钟
def index(request):
    pass
```

##### 场景

缓存主要适用于对页面实时性要求不高的页面。存放缓存的数据是频繁访问但是又不会经常修改的部分

- 个人博客
    - 如果用户平均一天更新一次，可以设置一天的全站缓存
- 购物网站
    - 商品描述信息可以缓存，购买数量需要实时更新
- 网页片段
    - 导航菜单
- 热点信息

##### 缓存设置

- `Memcached`
    - 高性能的分布式内存对象存储系统，原生支持最快的缓存系统
    - `pip install pyhon-memcached`
    - 不支持序列化缓存
- `redis`
    - 非关系型数据库
    - 支持缓存数据持久化
    - `master-slave` 数据备份
    - `pip install django-redis`
- 数据库缓存
    - `python manage.py createcachetable`
- 文件缓存
- 本地内存缓存
- `Dummy` 缓存
    - 不做任何实际存储，仅用于测试
- 测试缓存是否成功
    - `python manage.py shell`
    - `from django.core.cache import cache`
    - `cache.set('key', 'value', 60 * 1)`
    - `cache.has_key('k1'); cache.get('k1')`
- 选择缓存方式
    - 全站缓存
        - 依赖中间件实现，适用于静态网站或者动态内容很少的网站
    - 视图中使用
        - `@cache_page(60 * 15)`，仅适用于内容不怎么变的当个视图页面
    - 路由中使用
        - `@cache_page`
    - 模板中使用
        - `load cache` 加载过滤器，使用模板标签语法把需要的片段包裹起来
- 自定义缓存和清除缓存

```python
# memcache
# 本地缓存，使用localhost
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': '127.0.0.1:11211',
    }
}

# 使用unix soket通信
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': 'unix:/tmp/memcached.sock',
    }
}

# 分布式缓存，多台服务器，支持配置权重。
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': [
            '172.19.26.240:11211',
            '172.19.26.242:11211',
        ],
        # 我们也可以给缓存机器加权重，权重高的承担更多的请求，如下：
        'LOCATION': [
            ('172.19.26.240:11211', 5),
            ('172.19.26.242:11211', 1),
        ]
    }
}

# redis
CACHES = {

    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://your_host_ip:6379',  # redis所在服务器或容器ip地址
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
            "PASSWORD": "your_pwd",  # 你设置的密码
        },
    },
}

REDIS_TIMEOUT = 24 * 60 * 60
CUBES_REDIS_TIMEOUT = 60 * 30
NEVER_REDIS_TIMEOUT = 365 * 24 * 60 * 60

# 数据库缓存
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.db.DatabaseCache',
        'LOCATION': 'my_cache_table',
    }
}

# 文件系统缓存
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.filebased.FileBasedCache',
        'LOCATION': '/var/tmp/django_cache',  # 这个是文件夹的路径
        # 'LOCATION': 'c:\foo\bar',# windows下的示例
    }
}

# 本地内存缓存
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'unique-snowflake'  # 名字随便定
    }
}

# Dummy缓存， 不做任何缓存，仅用于测试
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.dummy.DummyCache',
    }
}

# 设置全站缓存，需要中间件顺序
MIDDLEWARE = [
    'django.middleware.cache.UpdateCacheMiddleware',  # 新增
    'django.middleware.common.CommonMiddleware',
    'django.middleware.cache.FetchFromCacheMiddleware',  # 新增
]
CACHE_MIDDLEWARE_ALIAS = 'default'  # 缓存别名
CACHE_MIDDLEWARE_SECONDS = '600'  # 缓存时间
CACHE_MIDDLEWARE_KEY_PREFIX = ''  # 缓存别名前缀

# 自定义缓存和清除缓存
from django.core.cache import cache

objects = cache.get('key')
if objects is None:
    objects = Model.objects.all()
    cache.set('key', objects)

cache.delete('key')
```

### 权限管理

约束用户行为和控制页面显示的一种机制。包含三个要素：用户，对象和权限，即什么用户对什么对象有什么权限
当我们在 `INSTALLED_APP` 里面添加应用后，`Django`
会自动为每一安装的模型自动创建四个可选的权限 `view`, `add`, `change`, `delete`

##### 用户权限

- `user.has_perm('app.change_model')` 查看用户当前权限 （app 名 + 权限动作 + 模型名）
    - 权限名组成部分
- 新增权限
    - 在 `Model` 的 `meta` 属性中添加权限
    - 使用 `ContentType` 程序创建权限
- 手动分配权限
    - 通过视图函数手动给用户分配权限
    - `user.user_permissions.add(permission1, permission2, ...)`
    - group.permissions.add(permission1, permission2, ...)`
    - `user.user_permissions.remove(permission1, permission2, ...)`
    - `user.user_permissions.clear()`

```python
# 新增自定义权限
class Article(models.Model):
    class Meta:
        permissions = (
            ("publish_article", "Can publish article"),
            ("comment_article", "Can comment article")
        )


# 使用 ContentType 程序创建权限
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType

content_type = ContentType.objects.get_for_model(model)
permission_1 = Permission.objects.create(
    codename='publish_article',
    name='Can publish article',
    content_type=content_type,
)
permission_2 = Permission.objects.create(
    codename='comment_article',
    name='Can comment article',
    content_type=content_type,
)
```

##### 权限缓存机制

`Django` 会缓存每个用户对象，包括权限。当代码中手动改变一个用户的权限后，必须重新获取该用户对象，更新最新权限

##### 用户权限验证

- `user.has_perm('app.change_model')`
- `@permission_required(perm, login_url=None, raise_exception=False)`
    - 如果指定 `login_url`，用户会被要求先登录，如果 `raise_exception=True`，会直接返回 `403` 无权限的错误，而不会跳转到登录页面
- 基于类的视图，需要使用 `PermissionRequiredMixin` 或者 `@method_decorator`
- 模板中使用
    - `perms` 全局变量
- 用户组
    - 和模型是多对多的关系，在权限控制时可以批量对用户权限进行管理和分配
- 不足
    - `Django` 自带的权限是针对模型，意味着无法对单独的对象进行权限管理

```python
from django.contrib.auth.mixins import PermissionRequiredMixin


class MyView(PermissionRequiredMixin, View):
    permission_required = 'polls.can_vote'
    # Or multiple of permissions:
    permission_required = ('polls.can_open', 'polls.can_edit')


from django.utils.decorators import method_decorator
from django.core.urlresolvers import reverse_lazy
from django.contrib.auth.decorators import user_passes_test


@method_decorator(user_passes_test(lambda u: Group.objects.get(name='admin') in u.groups.all()), name='dispatch')
class ItemDelete(DeleteView):
    model = Item
    success_url = reverse_lazy('items:index')

```

##### `Django-guardian`

基于对象的权限控制

- `pip install django-guardian`

> 一旦配置完毕，使用 `migrate` 命令将会创建匿名用户实例

```python
INSTALLED_APPS = (
    # ... 
    'guardian',
)

AUTHENTICATION_BACKENDS = (
    'django.contrib.auth.backends.ModelBackend',
    'guardian.backends.ObjectPermissionBackend',  # 添加身份认证
)

ANONYMOUS_USER_NAME = None  # 关闭匿名对象的权限
```

### 中间件

允许在一个浏览器请求到达视图之前处理它，以及在视图返回浏览器之前处理这个响应

- 权限校验，装饰器也可以用于用户权限校验（对单个视图），中间件可以全局修改
    - 禁止特定 `IP` 地址的用户或者未登录的用户访问视图
    - 对同一 `IP` 单位时间内发送请求数量做出限制
    - 视图函数执行之前传递额外参数或者变量
    - 执行后修改数据再返回
- 自定义中间件
    - `app.py` 目录下新建一个文件 `middleware.py`，添加好中间件，然后在 `settings.py` 中添加到 `MIDDLEWARE`
    - 函数中间件
    - 类中间件
- 钩子函数
    - `process_view`
        - 调用视图之前
    - `process_exception`
        - 视图函数中出现异常
    - `process_template_response`
        - 视图函数执行之后立刻执行

```python
def simple_middleware(get_response):
    # 一次性设置和初始化
    def middleware(request):
        # 请求在到达视图前执行的代码
        response = get_response(request)
        # 响应在返回给客户端前执行的代码
        return response

    return middleware


# settings
MIDDLEWARE = [
    'module.middleware.simple_middleware',  # 新增
]


# 类中间件
class SimpleMiddleware:
    def __init__(self, get_response):
        # 一次性设置和初始化
        self.get_response = get_response

    def __call__(self, request):
        # 视图函数执行前的代码
        response = self.get_response(request)
        # 视图函数执行后的代码
        return response


class LoginRequiredMiddleware:  # 全站登录案例
    def __init__(self, get_response):
        self.get_response = get_response
        self.login_url = settings.LOGIN_URL
        # 开放白名单，比如['/login/', '/admin/']
        self.open_urls = [self.login_url] + getattr(settings, 'OPEN_URLS', [])

    def __call__(self, request):
        if not request.user.is_authenticated and request.path_info not in self.open_urls:
            return redirect(self.login_url + '?next=' + request.get_full_path())

        response = self.get_response(request)
        return response
```

### 全局上下文管理器

向所有模板传递一个可以被全局使用的变量

- `Django` 内置的上下文管理器
    - `django.template.context_processors.request`
    - `django.contrib.auth.context_processors.auth`
    - `django.template.context_processors.debug`
    - `django.contrib.messages.context_processors.messages`
- 自定义全局上下文管理器
    - 本质上还是一个函数，必须满足三个条件
        - 传入参数必须含有 `request` 对象
        - 返回值必须是字典
        - 使用前需要在 `context_processors` 中申明
    - 通常定义在 `context_processors.py`，可以放在 `project` 或者 `app` 下面
- 全局变量的优先级高于视图里面的局部变量

```python
# app/context_processors.py
from django.conf import settings


def global_site_name(request):
    return {'site_name': settings.SITE_NAME, }


# settings
'context_processors' = [  # 以下包含了4个默认的全局上下文处理器
    'django.template.context_processors.debug',
    'django.template.context_processors.request',
    'django.contrib.auth.context_processors.auth',
    'django.contrib.messages.context_processors.messages',
    'app.context_processors.global_site_name',  # 自定义全局上下文处理器
]
```

### 信号

允许若干发送者通知一组接收者，某些特定的事件或者操作已经发生，接收者收到信号再去执行特定操作

- 工作机制
    - 发送者
        - 信号的发出方，可以是模型或者视图
    - 信号
    - 接收者
        - 信号接收者，本质上是一个简单的回调函数。将这个函数注册到信号上，当特定的信号发生，发送者发送信号，回调函数就会被执行
- 应用场景
    - 项目内不同事件的联动
        - 模型 A 变动时，模型 B 或者模型 C 收到信号之后同步更新
        - 数据变动时及时清除缓存
- 内置信号
    - `pre_save & post_save`
    - `pre_init& post_init`
    - `pre_delete & post_delete`
    - `m2m_changed`
    - `request_started & request_finished`
- `signals.py` 信号函数可以拆分出来单独写一个文件
- 自定义信号
    - 自定义信号
    - 触发信号
    - 监听函数与信号相关联
    -

```python
from django.core.cache import cache
from django.db.models.signals import post_delete, post_save
from django.dispatch import receiver


@receiver(post_save, sender=ModelA)
def cache_post_save_handler(sender, **kwargs):
    cache.delete('cached_a_objects')


@receiver(post_delete, sender=ModelA)
def cache_post_delete_handler(sender, **kwargs):
    cache.delete('cached_a_objects')


# 导入信号
# app.py
from django.apps import AppConfig


class AccountConfig(AppConfig):
    name = 'app'

    def ready(self):
        import app.signals


# __init__
default_app_config = 'app.apps.AccountConfig'

# 自定义信号
from django.dispatch import Signal

my_signal = Signal(providing_args=['msg'])


def index(request):
    signals.my_signal.send(sender=None, msg='Hello world')
    return render(request, template_name='index.html')


@receiver(my_signal)
def my_signal_callback(sender, **kwargs):
    print(kwargs['msg'])  # 打印Hello world!
```

### 自定义命令

可以执行独立的脚本或者命令，还可以通过 `Linux` 设置为定时任务

自定义的管理命令本质上是一个 `python` 脚本，需要放在特定的目录下面 `app/management/commands`，下划线开头的文件名不能作为管理命令
可以位于任何一个 `app` 下面

```python
from django.core.management.base import BaseCommand


class Command(BaseCommand):  # 必须使用这个名字
    # 帮助文本, 一般备注命令的用途及如何使用。
    help = 'Some help texts'

    # 处理命令行参数，可选，没有参数就不写
    def add_arguments(self, parser):
        parser.add_argument('name')  # 定义该参数是必选

    # 核心业务逻辑
    def handle(self, *args, **options):
        pass


# 检查数据库是否已经连接
import time
from django.db import connections
from django.db.utils import OperationalError
from django.core.management import BaseCommand


class Command(BaseCommand):
    help = 'Run data migrations until db is available.'

    def handle(self, *args, **options):
        self.stdout.write('Waiting for database...')
        db_conn = None
        while not db_conn:
            try:
                # 尝试连接
                db_conn = connections['default']
            except OperationalError:
                # 连接失败，就等待1秒钟
                self.stdout.write('Database unavailable, waiting 1 second...')
                time.sleep(1)

        self.stdout.write(self.style.SUCCESS('Database available!'))


# 周期性发送邮件
from datetime import timedelta, time, datetime
from django.core.mail import mail_admins
from django.core.management import BaseCommand
from django.utils import timezone
from django.contrib.auth import get_user_model

User = get_user_model()

today = timezone.now()
yesterday = today - timedelta(1)


class Command(BaseCommand):
    help = "Send The Daily Count of New Users to Admins"

    def handle(self, *args, **options):
        # 获取过去一天注册用户数量
        user_count = User.objects.filter(date_joined__range=(yesterday, today)).count()

        # 当注册用户数量多余1个，才发送邮件给管理员
        if user_count >= 1:
            message = "You have got {} user(s) in the past 24 hours".format(user_count)

            subject = (
                f"New user count for {today.strftime('%Y-%m-%d')}: {user_count}"
            )

            mail_admins(subject=subject, message=message, html_message=None)

            self.stdout.write("E-mail was sent.")
        else:
            self.stdout.write("No new users today.")
```

### `Celery`

项目中经常涉及一些耗时任务比如发送邮件，调用第三方程序。将它们异步化放在后台允许可以缩短请求响应的时间。同时还可以处理一些定时任务，清除缓存，备份数据库
`celery` 是一个基于分布式的消息传递队列。它通过消息传递任务，通常使用一个叫 `broker` 来协调 `client` 和 `worker`

- 安装环境
    - `redis`
    - `celery`
    - `django-celery-beat`
        - 设置定时任务或者周期性任务
        - `setting.py` 中添加
        - `admin` 后台添加
    - `django-celery-results`
        - 查看任务执行状态和结果
- 使用
    - 新增 `celery.py`
    - 修改 `__init__.py`
    - 配置 `settings`
- 测试 `celery`
    - `linux`
        - `Celery -A myproject worker -l info`
    - `win`
        - `Celery -A myproject worker -l info -P eventlet`
- 调用
    - `task_name.delay(args1, args2, kwargs=value_1, kwargs2=value_2)`
    - `task.apply_async(args=[arg1, arg2], kwargs={key:value, key:value})`
        - 支持更多参数

```python
# celery
import os
from celery import Celery

# 设置环境变量
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'myproject.settings')

# 实例化
app = Celery('myproject')

# namespace='CELERY'作用是允许你在Django配置文件中对Celery进行配置
# 但所有Celery配置项必须以CELERY开头，防止冲突
app.config_from_object('django.conf:settings', namespace='CELERY')

# 自动从Django的已注册app中发现任务
app.autodiscover_tasks()


# 一个测试任务
@app.task(bind=True)
def debug_task(self):
    print(f'Request: {self.request!r}')


# __init__.py
from .celery import app as celery_app

__all__ = ('celery_app',)

# settings.py
# 最重要的配置，设置消息broker,格式为：db://user:password@host:port/dbname
# 如果redis安装在本机，使用localhost
# 如果docker部署的redis，使用redis://redis:6379
CELERY_BROKER_URL = "redis://127.0.0.1:6379/0"

# celery时区设置，建议与Django settings中TIME_ZONE同样时区，防止时差
# Django设置时区需同时设置USE_TZ=True和TIME_ZONE = 'Asia/Shanghai'
CELERY_TIMEZONE = TIME_ZONE

# 配置结果查看
# 支持数据库django-db和缓存django-cache存储任务状态及结果
# 建议选django-db
CELERY_RESULT_BACKEND = "django-db"
# celery内容等消息的格式设置，默认json
CELERY_ACCEPT_CONTENT = ['application/json', ]
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'

# 配置文件添加周期任务
from datetime import timedelta

CELERY_BEAT_SCHEDULE = {
    "add-every-30s": {
        "task": "app.tasks.add",
        'schedule': 30.0,  # 每30秒执行1次
        'args': (3, 8)  # 传递参数-
    },
    "add-every-day": {
        "task": "app.tasks.add",
        'schedule': timedelta(hours=1),  # 每小时执行1次
        'args': (3, 8)  # 传递参数-
    },
}

# admin 添加周期任务
CELERY_BEAT_SCHEDULER = 'django_celery_beat.schedulers:DatabaseScheduler'
```

### `i18n`

- 新建 `locale` 文件夹，用来保存翻译消息文件（`.po` 和 `.mo`）
- 配置 `settings`

### `DRF`

`Django` 本身不符合 `REST` 规范，通过这个框架我们可以实现 `Web API`，主要提供了序列化器，认证，权限，分页，过滤和限流。

- `pip install djangorestframework`
- 配置 `settings`, `rest_framework`

##### 序列化

将属于自己语言的数据类型或对象转换为可以通过网络传输或者可以存储到本地磁盘的数据格式，这个过程叫做序列化。
`Django` 有属于自己的数据类型（比如`QuerySet`），还提供 `serializers` 类

```python
from django.core import serializers

data = serializers.serialize("json", SomeModel.objects.all())
```

##### `REST` 规范

`URI` 代表资源
`Django` 中有些请求方法不支持

##### 自定义序列化器

将模型实例序列号或者反序列化成如 `json` 之类的表示形式。
序列化器定义了需要对模型实例的哪些字段序列化或者反序列化，并对客户端发送过来的数据进行验证和存储

- `Serializer`
    - `serializers.py`
    - 定义序列化或者反序列化字段
    - `create` `update`
        - 定义在调用 `serializer.save` 时如何创建和修改完整的实例
- `ModelSerializer`
- 改变序列化器的输出
- `SerializerMethodField`
    - 将任意类型数据添加到对象的序列化表中，常用来定义原本不存在的字段
- `to_representation`
    - 改变序列化输出的内容
- 字段对应的实际为模型对象
    - 嵌套序列化器
    - 设置关联模型深度
        - 会展示关联模型的所有信息，包括敏感字段
- 关系序列化
    - `PrimaryKeyRelatedField`
        - `id` 形式展示关联
    - `StringRelatedField`
        - 调用关联对象 `__str__`
- 数据验证
    - `is_valid`
        - 反序列化时验证用户数据
    - 字段级别验证
        - 添加方法`.validate_字段名`
        - 如果序列器里面定义了 `required=False` 则不会进行这一步
    - 对象级别验证
        - `.validate`
            - 执行多个字段验证，入参为字典
- 动态加载验证器
    - 重写 `get_serializer_class`

```python
from rest_framework import serializers
from .models import Article
from django.contrib.auth import get_user_model

User = get_user_model()


class ArticleSerializer(serializers.Serializer):
    id = serializers.IntegerField(read_only=True)
    title = serializers.CharField(required=True, allow_blank=True, max_length=90)
    body = serializers.CharField(required=False, allow_blank=True)
    author = serializers.ReadOnlyField(source="author.id")
    status = serializers.ChoiceField(choices=Article.STATUS_CHOICES, default='p')
    create_date = serializers.DateTimeField(read_only=True)

    def create(self, validated_data):
        """
        Create a new "article" instance
        """
        return Article.objects.create(**validated_data)

    def update(self, instance, validated_data):
        """
        Use validated data to return an existing `Article`instance。"""
        instance.title = validated_data.get('title', instance.title)
        instance.body = validated_data.get('body', instance.body)
        instance.status = validated_data.get('status', instance.status)
        instance.save()
        return instance


from rest_framework import serializers


class TempSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=100)


class ArticleSerializer(serializers.ModelSerializer):
    temp = TempSerializer()  # 嵌套序列化器
    author = serializers.HiddenField(default=serializers.CurrentUserDefault())  # 隐藏字段，request 的时候自动写入
    status = serializers.ReadOnlyField(source="get_status_display")  # 覆盖原来字段的值，新的值为方法的返回值
    full_status = serializers.ReadOnlyField(source="get_status_display")  # 如果修改该属性会导致反序列化的时候该值无法修改，新增一个字段比较推荐
    cn_status = serializers.SerializerMethodField()

    class Meta:
        model = Article
        fields = '__all__'
        read_only_fields = ('id', 'author', 'create_date')
        depth = 1  # 关联模型深度

    def get_cn_status(self, obj):
        if obj.status == '1':
            return "一"
        elif obj.status == '2':
            return "二"
        else:
            return ''

    def to_representation(self, value):
        data = super().to_representation(value)
        data['other'] = "other"
        return data

    def validate(self, data):
        if data['start'] > data['finish']:
            raise serializers.ValidationError("finish must occur after start")
        return data


class UserSerializer(serializers.ModelSerializer):
    articles = serializers.PrimaryKeyRelatedField(many=True, read_only=True)

    class Meta:
        model = User
        fields = ('id', 'username', 'articles',)
        read_only_fields = ('id', 'username',)

```

##### 视图

- `@api_view`
    - 强调了 `api` 视图，并限定可以接收的请求方法
    - 提供更多请求方式
        - `request.POST` 只处理表单数据，只处理 `POST`
        - `request.data` 可以处理任何数据
- 基于类的视图
    - 使用 `APIView`
        - 继承 `django` 中的 `View`，按照请求方法调用不同参数
        - 支持更多请求方法
        - `request` 升级，可以使用 `request.data` 获取不同方法发送过来的数据
    - `Mixins` 和 `GenericAPIView`
        - 简化代码行数
        - `GenericAPIView` 继承 `APIView`，提供基础功能
        - `Mixins` 提供了通用功能
            - `ListModelMixin`
            - `CreateModelMixin`
            - `RetrieveModelMixin`
            - `UpdateModelMixin`
            - `DestroyModelMixin`
    - 通用视图 `generics.*`
        - 开箱即用
    - 视图集 `ViewSet` `ModelViewSet`
        - 进一步减少代码
        - `ModelViewSet`
            - 支持五种常见的视图
        - `ReadOnlyModelViewSet`
            - 仅支持两种可读的视图
- `URL` 添加格式化后缀
    - `http://example.com/api/items/4.json`
    - `http://example.com/api/items/4.text`

> 定义序列化器的时候需要表明哪些字段是可读的，哪些字段是可写的，哪些字段是只读的

```python
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import Article
from .serializers import ArticleSerializer


@api_view(['GET', 'POST'])
def article_list(request):
    if request.method == 'GET':
        articles = Article.objects.all()
        serializer = ArticleSerializer(articles, many=True)
        return Response(serializer.data)

    elif request.method == 'POST':
        serializer = ArticleSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(author=request.user)  # 序列化容器中该字段是只读，请求无法修改，代码里面手动修改
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


from django.urls import re_path
from rest_framework.urlpatterns import format_suffix_patterns
from . import views

urlpatterns = [
    re_path(r'^articles/$', views.article_list),
    re_path(r'^articles/(?P<pk>[0-9]+)$', views.article_detail), ]

urlpatterns = format_suffix_patterns(urlpatterns)
```

```python
from rest_framework import mixins
from rest_framework import generics


class ArticleList(mixins.ListModelMixin,  # 用户发送 get 调用提供的 list
                  mixins.CreateModelMixin,  # 发送 post 调用提供的 create
                  generics.GenericAPIView):
    queryset = Article.objects.all()
    serializer_class = ArticleSerializer

    def get(self, request, *args, **kwargs):
        return self.list(request, *args, **kwargs)

    def post(self, request, *args, **kwargs):
        return self.create(request, *args, **kwargs)

    # 将request.user与author绑定。调用create方法时执行如下函数。
    def perform_create(self, serializer):
        serializer.save(author=self.request.user)
```

```python
from rest_framework import viewsets


class ArticleViewSet(viewsets.ModelViewSet):
    # 用一个视图集替代ArticleList和ArticleDetail两个视图
    queryset = Article.objects.all()
    serializer_class = ArticleSerializer

    # 自行添加，将request.user与author绑定
    def perform_create(self, serializer):
        serializer.save(author=self.request.user)


# url
article_list = views.ArticleViewSet.as_view(
    {
        'get': 'list',
        'post': 'create'
    })

article_detail = views.ArticleViewSet.as_view({
    'get': 'retrieve',  # 只处理get请求，获取单个记录
})

urlpatterns = [
    re_path(r'^articles/$', article_list),
    re_path(r'^articles/(?P<pk>[0-9]+)$', article_detail),
]

urlpatterns = format_suffix_patterns(urlpatterns)
```

##### 认证和权限

认证是指通过用户提供的 `ID` 密码或者 `Token` 来验证用户身份。权限校验发生在验证用户身份之后

- 认证
    - `SessionAuthentication`
        - 需要存储到服务器
        - 基于 `cookie` 进行用户识别，容易被截获
        - 存储本地，无法共享
    - `BasicAuthentication`
    - `RemoteUserAuthentication` 不常用
    - `TokenAuthentication`
        - 推荐
        - 无需存储，减低服务器压力
        - 可以实现服务器之间共享
        - 支持跨域访问
    - 自定义认证
- 权限
    - `IsAuthenticatedOrReadOnly`
        - 经过身份验证的获取读写权限，未经过的只读
    - `IsAuthenticated`
    - `IsAdminUser`
    - `AllowAny`
    - `DjangoModelPermissions`
    - `DjangoModelPermissionsOrAnonReadOnly`
    - `DjangoObjectPermissions`
    - 自定义权限
- `JWT`
    - `JSON Web Token`，定义一种紧凑自包含的方式，将数据以 `JSON` 对象传输
    - 紧凑
        - 数据少
    - 自包含
        - 涉及到一些关键信息（用户 `id`）
    - 使用
        - `pip install djangorestframework-simplejwt`
        - 自定义令牌
        - 自定义认证后台

```python
from rest_framework import generics
from rest_framework import permissions
from .permissions import IsOwnerOrReadOnly


class ArticleList(generics.ListCreateAPIView):
    queryset = Article.objects.all()
    serializer_class = ArticleSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)


# 自定义权限
from rest_framework import permissions


class CustomerPermission(permissions.BasePermission):
    message = 'You have not permissions to do this.'

    def has_permission(self, request, view):
        ...

    def has_object_permission(self, request, view, obj):
        ...


# setting 配置默认全局认证
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework.authentication.BasicAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    )}

from rest_framework.decorators import api_view, authentication_classes, permission_classes


@api_view(['GET'])
@authentication_classes((SessionAuthentication, BasicAuthentication))
@permission_classes((IsAuthenticated,))
def example_view(request, format=None):
    content = {
        'user': unicode(request.user),  # `django.contrib.auth.User` 实例。
        'auth': unicode(request.auth),  # None
    }
    return Response(content)


class ExampleView(APIView):
    authentication_classes = (SessionAuthentication, BasicAuthentication)
    permission_classes = (IsAuthenticated,)


# 自定义认证
class ExampleAuthentication(authentication.BaseAuthentication):
    def authenticate(self, request):
        username = request.META.get('X_USERNAME')
        if not username:
            return None

        try:
            user = User.objects.get(username=username)
        except User.DoesNotExist:
            raise exceptions.AuthenticationFailed('No such user')

        return (user, None)


# 使用携带的 token
INSTALLED_APPS = (
    'rest_framework.authtoken'
)
from django.conf import settings
from django.db.models.signals import post_save
from django.dispatch import receiver
from rest_framework.authtoken.models import Token


@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def create_auth_token(sender, instance=None, created=False, **kwargs):
    if created:
        Token.objects.create(user=instance)


# JWT
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
}

from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

router = DefaultRouter()
router.register(r'product', ProductViewSet, basename='Product')
router.register(r'image', ImageViewSet, basename='Image')

urlpatterns = [
    path('admin/', admin.site.urls),
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('', include(router.urls)),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

from rest_framework_simplejwt.serializers import TokenObtainPairSerializer


class MyTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super(MyTokenObtainPairSerializer, cls).get_token(user)

        # 添加额外信息
        token['username'] = user.username
        return token


from django.contrib.auth.backends import ModelBackend

# setting
AUTHENTICATION_BACKENDS = (
    'users.views.MyCustomBackend',
)

User = get_user_model()


class MyCustomBackend(ModelBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        try:
            user = User.objects.get(Q(username=username) | Q(email=username))
            if user.check_password(password):
                return user
        except Exception as e:
            return None
```

##### 分页

- `PageNumberPagination`
    - 普通分页
- `LimitOffsetPagination`
    - 偏移分页
- `CursorPagination`
    - 加密分页
- 自定义分页
    - `pagination.py`

```python
# 默认显示两页
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 2
}
# 自定义分页
from rest_framework.pagination import PageNumberPagination


class MyPageNumberPagination(PageNumberPagination):
    page_size = 2  # default page size
    page_size_query_param = 'size'  # ?page=xx&size=??
    max_page_size = 10  # max page size


from .pagination import MyPageNumberPagination


class ArticleViewSet(viewsets.ModelViewSet):
    # 用一个视图集替代ArticleList和ArticleDetail两个视图
    queryset = Article.objects.all()
    serializer_class = ArticleSerializer
    pagination_class = MyPageNumberPagination

    def get_paginated_response(self, data):  # 改变响应数据格式，可以新增额外内容
        return Response({
            'links': {
                'next': self.get_next_link(),
                'previous': self.get_previous_link()
            },
            'count': self.page.paginator.count,
            'results': data
        })
```

##### 过滤和排序

- 过滤
    - 重写`get_queryset`方法
        - 只适用于需要过滤字段比较少的模型
    - `django-filter`
        - `pip install django-filter`
        - 自定义 `fileset`
            - `filters.py`
    - `SearchFilter`
        - 使用一个关键字对模型某个字段或者多个字段进行搜索
        - 自定义
- 排序
    - `OrderingFilter`

```python
class ArticleList(generics.ListCreateAPIView):
    serializer_class = ArticleSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)
    pagination_class = MyPageNumberPagination

    def get_queryset(self):
        keyword = self.request.query_params.get('q')  # 获取 GET 请求发来的参数
        if not keyword:
            queryset = Article.objects.all()
        else:
            queryset = Article.objects.filter(title__icontains=keyword)
        return queryset


INSTALLED_APPS = [
    "django_filters",
]

REST_FRAMEWORK = {
    'DEFAULT_FILTER_BACKENDS': ['django_filters.rest_framework.DjangoFilterBackend']
}


class ArticleList(generics.ListCreateAPIView):
    # new: filter backends and classes
    filter_backends = (rest_framework.DjangoFilterBackend,)
    filter_fields = ['title', 'author']


# 自定义
import django_filters
from .models import Article


class ArticleFilter(django_filters.FilterSet):
    q = django_filters.CharFilter(field_name='title', lookup_expr='icontains')

    class Meta:
        model = Article
        fields = ('title', 'status')


class ArticleList(generics.ListCreateAPIView):
    queryset = Article.objects.all()
    serializer_class = ArticleSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)
    pagination_class = MyPageNumberPagination

    # new: filter backends and classes
    filter_backends = (rest_framework.DjangoFilterBackend,)
    filter_class = ArticleFilter


from rest_framework import filters


class ArticleList(generics.ListCreateAPIView):
    queryset = Article.objects.all()
    serializer_class = ArticleSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)
    pagination_class = MyPageNumberPagination

    # new: add SearchFilter and search_fields
    filter_backends = (filters.SearchFilter,)
    search_fields = ('title',)

    # associate request.user with author.
    def perform_create(self, serializer):
        serializer.save(author=self.request.user)


from rest_framework import filters


class CustomSearchFilter(filters.SearchFilter):
    def get_search_fields(self, view, request):
        if request.query_params.get('title_only'):
            return ['title']
        return super(CustomSearchFilter, self).get_search_fields(view, request)


# 排序
from rest_framework import filters


class ArticleList(generics.ListCreateAPIView):
    queryset = Article.objects.all()
    serializer_class = ArticleSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)
    pagination_class = MyPageNumberPagination

    filter_backends = (filters.SearchFilter, filters.OrderingFilter,)
    search_fields = ('title',)
    ordering_fields = ('create_date')
```

##### 限流

限制客户端对 `API` 的调用频率

- 针对单个用户
    - `AnonRateThrottle`
        - 限制未认证用户， IP地址来确定用户身份
    - `UserRateThrottle`
        - 限定认证用户
- 针对所有用户和
    - `ScopeRateThrottle`
        - 对 `API` 特定部分的访问
- 全局限流
- 视图限流
    - `throttles.py`
    - 会覆盖全局限流设置

```python
REST_FRAMEWORK = {
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',

    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '2/min',
        'user': '10/min',
        'limit_per_minute': '5/min',  # 新增
        'limit_per_hour': '500/hour',  # 新增
    }
}

from rest_framework.throttling import AnonRateThrottle, UserRateThrottle


class ArticleListAnonRateThrottle(AnonRateThrottle):
    THROTTLE_RATES = {"anon": "5/min"}


class ArticleListUserRateThrottle(UserRateThrottle):
    THROTTLE_RATES = {"user": "30/min"}


from .throttles import ArticleListAnonRateThrottle, ArticleListUserRateThrottle


class ArticleList(generics.ListCreateAPIView):
    queryset = Article.objects.all()
    serializer_class = ArticleSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)
    pagination_class = MyPageNumberPagination
    throttle_classes = [ArticleListAnonRateThrottle, ArticleListUserRateThrottle]

class ArticleListView(APIView):
    throttle_scope = 'article_list' # 指定限流范围

REST_FRAMEWORK = {
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
        'rest_framework.throttling.ScopedRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '2/min',
        'user': '10/min',
        'article_list':'1000/day', # 新增
        'article_detail': '100/hour', # 新增
    }
}

# 自定义限流，十个请求里面放一个
class RandomRateThrottle(throttling.BaseThrottle):
    def allow_request(self, request, view):
        return random.randint(1, 10) != 1
```