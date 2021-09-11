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
$ (master)kubectl exec -it -n prod backend-dep-96b679785-zg4gc -- curl http://localhost:9000
{"detail":"Not Found"}
```
Аналогично проверяем сервер СУБД:
```bash


Все файлы находятся по [пути](https://github.com/Protosuv/kubernetes_homework/tree/master/13.1/13-kubernetes-config/task2 "путь").