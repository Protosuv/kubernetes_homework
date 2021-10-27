# Домашнее задание к занятию "13.4 инструменты для упрощения написания конфигурационных файлов. Helm и Jsonnet"

## Предварительная подготовка

1. В задании используется раннее настроенный кластер из трёх нод: control plane и две worker ноды. Управление кластером осуществляется с рабочего ноутбука, путём переноса конфигурации кластера в папку пользователя. До работы над текущим заданием, из кластера были удалены все сущности: поды, развёртывания и т.д.

## Задание 1: подготовка helm чарта для приложения

2. Наиболее подходящим для использования в качестве заготовки для чарта, было использование наработок из [ДЗ 13.1]( https://github.com/Protosuv/kubernetes_homework/tree/master/13.1/13-kubernetes-config/task2 "ДЗ 13.1") (второго варианта из этого задания).  
Первоначально был установлен helm по стандартной инструкции из официального сайта. Также, для удобства, были настроены автодополнения для команд, по аналогии с kubectl.  

Создаём шаблон чарта при помощи команды:

```bash
$ helm create my-chart
```

Затем, находясь в папке с чартом, были проделаны действия по адаптации deploy, sts и так далее, но для использования в виде шаблонов. Также был добавлен шаблон для развёртывания PVC. После подготовки чарта, его нужно проверить:

```bash
$ helm lint my-chart/
==> Linting my-chart/
[INFO] Chart.yaml: icon is recommended
[ERROR] templates/: template: my-chart/templates/NOTES.txt:8:39: executing "my-chart/templates/NOTES.txt" at <.Values.service.type>: wrong type for value; expected string; got interface {}

Error: 1 chart(s) linted, 1 chart(s) failed
```

Не совсем ясно, почему выпадает ошибка, при том, что этот файл был сгенерирован прошлой командой. Для ускорения решения домашней задачи, содержимое файла было удалено, после чего отработка команды прошла без проблем:

```bash
$ helm lint my-chart/
==> Linting my-chart/
[INFO] Chart.yaml: icon is recommended
1 chart(s) linted, 0 chart(s) failed
```

3. На этом этапе можно сгенерировать, то, что выдаётся при сборке шаблона:

```bash
helm template netology-demo my-chart/ >netology-demo.yaml
```
В итоге система выдаёт готовый манифест, который [доступен по ссылке](https://github.com/Protosuv/kubernetes_homework/blob/master/13.4/netology-demo.yaml "ссылка").

## Задание 2: запустить 2 версии в разных неймспейсах

4. Для того, чтобы запустить чарты в разных неймспейсах, можно воспользоваться ключами в командной строке и получить нужный результат:

```bash
$ helm upgrade v1 ./my-chart/ --install --namespace app-v1
Release "v1" does not exist. Installing it now.
Error: create: failed to create: namespaces "app-v1" not found
```
Сообщается об ошибке, что отсутствует такой неймспейс, следовательно, нужно его создать, а для этого синтаксис команды изменится:
```bash
$ helm upgrade v1 ./my-chart/ --install --create-namespace --namespace app-v1
Release "v1" does not exist. Installing it now.
NAME: v1
LAST DEPLOYED: Wed Oct 27 17:23:45 2021
NAMESPACE: app-v1
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
```
Снизу отображается первая строчка файла NOTES.txt.
Можно посмотреть, что есть в системе:

```bash
$ helm list --all-namespaces -d
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION   
v1              app-v1          1               2021-10-27 17:23:45.982816536 +0300 MSK deployed        my-chart-0.1.0  1.16.0
```
Для получения результатов другой части задания, команда модифицируется:

```bash
$ helm upgrade v2 ./my-chart/ --install --create-namespace --namespace app-v1
$ helm upgrade v3 ./my-chart/ --install --create-namespace --namespace app-v2
```
Смотрим в каком неймспейсе какой чарт и какой версии находится:

```bash
$ helm list --all-namespaces -d
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
v1              app-v1          1               2021-10-27 17:23:45.982816536 +0300 MSK deployed        my-chart-0.1.0  1.16.0     
v2              app-v1          1               2021-10-27 17:26:36.155406281 +0300 MSK deployed        my-chart-0.1.0  1.16.0     
v3              app-v2          1               2021-10-27 17:27:06.540551898 +0300 MSK deployed        my-chart-0.1.0  1.16.0
```
