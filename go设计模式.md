# 设计模式

### 功能选择

```go
package main

type CoffeeOptions struct {
	sugar        int
	milk         int
	coffeePowder int
}

type CoffeeOption func(*CoffeeOptions)

func CoffeeSugar(sugar int) CoffeeOption {
	return func(options *CoffeeOptions) {
		opts.sugar = sugar
	}
}

func CoffeeMilk(milk int) CoffeeOption {
	return func(options *CoffeeOptions) {
		opts.milk = milk
	}
}

func CoffeePowder(powder int) CoffeeOption {
	return func(options *CoffeeOptions) {
		opts.coffeePowder = powder
	}
}

func newDefaultCoffeeOptions() *CoffeeOptions {
	return &CoffeeOptions{
		sugar:        0,
		milk:         0,
		coffeePowder: 0,
	}
}

func NewCoffee(opts ...CoffeeOption) *Coffee {
	defaultOptions := newDefaultCoffeeOptions()

	for _, opt := range opts {
		opt(defaultOptions)
	}

	return defaultOptions
}

func main() {
	opts := NewCoffee(
		CoffeeSugar(1),
		CoffeeMilk(2),
		CoffeePowder(3),
	)
}

```

### 工厂模式

##### 简单工厂

```go
type Person struct {
Name string
Age  int
}

func (p Person) Greet() {
fmt.Println("Hello, my name is", p.Name, "and I am", p.Age, "years old.")
}

fun NewPerson(name string, age int) *Person {
return &Person{
Name: name,
Age:  age,
}
}
```

##### 抽象工厂

和简单工厂相比唯一的区别是一个返回结构体，一个返回接口；不公开内部实现的情况下，让内部调用者实现各种功能

##### 工厂方法模式

依赖工厂方法模式中，我们可以通过实现工厂接口来创建多种工厂，将对象创建由一个对象负责所有具体类的实例化，变成一群对象负责具体类的实例化

```go
type Person struct {
name string
age int
}

func NewPersonFactory(age int) func (name string) Person {
return func (name string) Person {
return Person{
name: name,
age: age,
}
}
}

```

### 单例模式

```go
package conn

import (
	"fmt"
	"sync"
	"time"

	"github.com/pkg/errors"

	"github.com/driver/mysql"
	"github.com/gorm"
	"github.com/gotm/logger"
)

type database struct {
	instance *gorm.DB
}

var db struct {
	database
	sync.Once
}

func DB() *gorm.DB {
	db.Do(func() {
		db.init()
	})
	return db.instance
}

func (d *database) init() {
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8mb4&parseTime=true&loc=Local&timeout=10s",
		"Username",
		"Password",
		"Host",
		"Port",
		"DBName",
	)

	var err error
	d.instance, err = gorm.Open(mysql.Open(dsn), &gorm.Config{Logger: logger.Default.LogMode(logger.Info)})
	if err != nil {
		panic(errors.WithMessage(err, "gorm connect mysql failed"))
	}
	sqlDB, _ := d.instance.DB()
	sqlDB.SetMaxIdleConns(100)
	sqlDB.SetMaxOpenConns(100)
	sqlDB.SetConnMaxLifetime(time.Hour)
}

```

### 模板模式

定义操作中的算法骨架，将一些步骤延迟到子类；将一个类中能公共使用的方法在抽象类中实现，不能的作为抽象方法，强制使用子类去实现

```go
package template

type Cooker interface {
	fire()
	cooke()
	outfire()
}

type CookMenu struct {
}

func (CookMenu) fire() {
	println("fire")
}

func (CookMenu) cooke() {
}

func (CookMenu) outfire() {
	println("outfire")
}

func doCook(cooker Cooker) {
	cooker.fire()
	cooker.cooke()
	cooker.outfire()
}

type Tomato struct {
	CookMenu
}

func (*Tomato) cook() {
	println("tomato cook")
}
```

### 策略模式

定义一组算法，将每个算法封装起来，并且他们之间可以互相转换

```go
package strategy

type IStrategy interface {
	do(int, int) int
}

type add struct{}

func (*add) do(a, b int) int {
	return a + b
}

type reduce struct{}

func (*reduce) do(a, b int) int {
	return a - b
}

type Operator struct {
	strategy IStrategy
}

func (o *Operator) SetStrategy(s IStrategy) {
	o.strategy = s
}

func (o *Operator) Calculate(a, b int) int {
	return o.strategy.do(a, b)
}
```

### 责任链模式

允许将请求沿着处理者链进行发送，直至其中一个处理者对其处理；允许多个对象对请求进行处理

```go
type department interface {
    execute(*patient)
    setNext(department)
}

type patient struct {
    name string
    registrationDone bool
    doctorCheckUpDone bool
    medicalPrescriptionDone bool
    paymentDone bool
}

type reception struct {
    next department
}

func (r *reception) execute(p *patient) {
    if p.registrationDone {
		fmt.Println("Patient registration already done")
		r.next.execute(p)
		return
	}
	fmt.Println("Reception registering patient")
	p.registrationDone = true
	r.next.execute(p)
}

func (r *reception) setNext(next department) {
	r.next = next
}

type doctor struct {
	next department
}

func (d *doctor) execute(p *patient) {
	if p.doctorCheckUpDone {
		fmt.Println("Doctor checkup already done")
		d.next.execute(p)
		return
	}
	fmt.Println("Doctor checking patient")
	p.doctorCheckUpDone = true
	d.next.execute(p)
}

func (d *doctor) setNext(next department) {
	d.next = next
}

```