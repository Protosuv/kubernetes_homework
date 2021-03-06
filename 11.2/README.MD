# Домашнее задание к занятию "11.02 Микросервисы: принципы"

## Задача 1: API Gateway

---
Поиск информации по возможным системам, позволяющим реализовать функционал API Gateway показал весьма обширные результаты. Некоторые продукты уже давно на рынке, некоторые совсем недавно. В итоге получился такой список:  
**Azure  
Istio  
Yandex API Gateway  
Amazon API Gateway  
Oracle API Gateway  
Google API Gateway (Apigee API Management)    
Tyk API Gateway**

Фактически, все перечисленные API Gateway реализовывают базовые сущности, которые затребованы в задаче. Фактический выбор осложняется отсутствием опыта работы с этими сервисами.  
Облачные сервисы вендоров (Яндекс, AWS и т.д.) часто завязаны на экосистему самого вендора и наиболее быстро, легко настраиваются именно под эти сервисы. В тоже время, хотелось бы иметь некоторую свободу выбора. В таком случае выбор сужается до Tyk и Istio. Причём, в случае с Istio, то продукт в общем случае реализует так называемый service mesh. Фактически это микро-прокси смотрящие в сторону любого микросервиса и работающие с трафиком на высоком уровне (L7). Продукт Tyk - это хорошо документированная и производительная opensource платформа, реализующая среди прочего и функционал API Gateway. Самое интересное, что можно сделать связку из Tyk и Istio, где каждый продукт будет выполнять свой объём функций.  
>В связи с изложенным выше, в силу отсутствия опыта, но высокого инженерного интереса, я бы сделал выбор из комбо двух продуктов Tyk и Istio.

## Задача 2: Брокер сообщений

---

Анализ многочисленной информации в сети интернет как за последние годы, так и в принципе, показал, что есть такие продукты, реализующие функционал MQ:

**RocketMQ   
ZeroMQ  
Kafka  
RabbitMQ  
Redis  
ActiveMQ**

Опыта работы с любым из этих продуктов нет, но всегда можно собрать впечатляющий фидбек как от инженеров одиночек, так и больших профессиональных команд, которые использовали эти приложения в прод среде под высокой нагрузкой. Из перечисленных продуктов, Redis строго говоря не является брокером сообщений, но есть кейсы, в которых эта noSQL БД используется под подобного рода задачи. Чтение пользовательских историй в целом показывает, что очень популярен продукт Apache Kafka. Многими отмечается его высокая производительность, динамичное развитие продукта, появление новых фич и избавление от досадных недостатков. Продукт хорошо документирован, имеет высокое информационное наполнение по различным аспектам его использования, есть хорошее комьюнити.  
> Таким образом, для меня, как начинающего инженера выбор тут очевиден - это Apache Kafka.

---
