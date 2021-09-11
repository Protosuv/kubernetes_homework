# Домашнее задание к занятию "13.3 работа с kubectl"
1. Используется уже работающий кластер из трёх нод.
## Работа с EXEC
```html
$ kubectl exec -it -n prod frontend-dep-6f94bf4c9b-5j4dl -- bash
root@frontend-dep-6f94bf4c9b-5j4dl:/app# curl http://localhost
<!DOCTYPE html>
<html lang="ru">
<head>
    <title>Список</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="/build/main.css" rel="stylesheet">
</head>
<body>
    <main class="b-page">
        <h1 class="b-page__title">Список</h1>
        <div class="b-page__content b-items js-list"></div>
    </main>
    <script src="/build/main.js"></script>
</body>
</html> 
```
То есть был осуществлён вход в работающий контейнер, где уже внутри выполнялась команда curl. Альтернативно, можно выполнить эту же команду сразу же. Проверяем на backend:
```json
$ kubectl exec -it -n prod backend-dep-96b679785-zg4gc -- curl http://localhost:9000
{"detail":"Not Found"}
```
Аналогично проверяем сервер СУБД:
```bash
$ kubectl exec -it -n prod postgresql-db-0 -- psql -U postgres
psql (13.4 (Debian 13.4-1.pgdg100+1))
Type "help" for help.

postgres=#
```
## Работа с PORT-FORWARD
```html
 $ kubectl port-forward -n prod frontend-dep-6f94bf4c9b-5j4dl 8090:80 &
[1] 115155
Forwarding from 127.0.0.1:8090 -> 80
curl http://localhost:8090
Handling connection for 8090
<!DOCTYPE html>
<html lang="ru">
<head>
    <title>Список</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="/build/main.css" rel="stylesheet">
</head>
<body>
    <main class="b-page">
        <h1 class="b-page__title">Список</h1>
        <div class="b-page__content b-items js-list"></div>
    </main>
    <script src="/build/main.js"></script>
</body>
</html>
```
Проверяем бекенд и СУБД:
```json
$ kubectl port-forward -n prod backend-dep-96b679785-zg4gc 9090:9000 &
[2] 115987
$ Forwarding from 127.0.0.1:9090 -> 9000
curl http://localhost:9090
Handling connection for 9090
{"detail":"Not Found"}
```
```bash
 Forwarding from 127.0.0.1:15432 -> 5432
psql -U postgres -h localhost -p 15432
Handling connection for 15432
psql (12.8 (Ubuntu 12.8-0ubuntu0.20.04.1), server 13.4 (Debian 13.4-1.pgdg100+1))
WARNING: psql major version 12, server major version 13.
         Some psql features might not work.
Type "help" for help.

postgres=# 
```
Сразу следует отметить особенность команды port-forward применительно к Postgresql. Первоначальный запуск приводит к ошибке:
```
$ psql -U postgres -h localhost -p 15432
bash: psql: команда не найдена
```
Потому как на хостовой системе нет команды psql, которая была бы внутри контейнера в случае использования EXEC. Для решения этой задачи, потребовалось установить пакет:
```bash
$ apt install postgresql-client
```  
2. Используем масштабирование на наших ресурсах при помощи их редактирования:
```bash
$ kubectl edit -n prod deploy backend-dep
deployment.apps/backend-dep edited
$ kubectl get  deploy -n prod
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
backend-dep    3/3     3            3           47m
frontend-dep   1/1     1            1           47m
```
Видно, что количество подов стало 3 штуки. Аналогично для фронтенда:
```bash
$ kubectl edit -n prod deploy frontend-dep 
deployment.apps/frontend-dep edited
$ kubectl get  deploy -n prod
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
backend-dep    3/3     3            3           50m
frontend-dep   2/3     3            2           50m
```
Видно, что не запустился один под. Можно узнать каков его статус:
```bash
$ kubectl get pods -n prod -o wide
NAME                                  READY   STATUS    RESTARTS   AGE     IP             NODE     NOMINATED NODE   READINESS GATES
backend-dep-96b679785-wcz8v           1/1     Running   0          3m54s   10.233.96.32   node2    <none>           <none>
backend-dep-96b679785-wdfm7           1/1     Running   0          3m54s   10.233.96.31   node2    <none>           <none>
backend-dep-96b679785-zg4gc           1/1     Running   0          51m     10.233.96.30   node2    <none>           <none>
frontend-dep-6f94bf4c9b-2bwtm         1/1     Running   0          52s     10.233.92.25   node3    <none>           <none>
frontend-dep-6f94bf4c9b-5j4dl         1/1     Running   0          51m     10.233.92.24   node3    <none>           <none>
frontend-dep-6f94bf4c9b-zgwlz         0/1     Pending   0          52s     <none>         <none>   <none>           <none>
```
То есть он должен запускаться на ноде 3, но не запланирован к запуску, вероятно из-за нехватки ресурсов:
```bash
$ kubectl get events -n prod
4m30s       Warning   FailedScheduling    pod/frontend-dep-6f94bf4c9b-zgwlz    0/3 nodes are available: 3 Insufficient cpu.
```
Уменьшаем количество подов как было:
```bash
$ kubectl edit -n prod deploy backend-dep
deployment.apps/backend-dep edited
$ kubectl edit -n prod deploy frontend-dep 
deployment.apps/frontend-dep edited
$ (master)kubectl get deploy -n prod
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
backend-dep    1/1     1            1           59m
frontend-dep   1/1     1            1           59m
```
Всё стало как прежде, то есть количество подов стало по 1 штуке в каждом развёртывании.
