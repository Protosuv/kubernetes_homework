# Домашнее задание к занятию "14.5 SecurityContext, NetworkPolicies"

## Задача 1: Рассмотрите пример 14.5/example-security-context.yml

Для запуска ресурсов используется преднастроенный раннее кластер из 3 нод в Digital Ocean.

Первоначальный запуск пода из манифеста, приводил к ошибке. Чтобы под корректно запускался, в манифесте была закомментирована строка:
```yaml
command: [ "id" ]
```
и снят комментарий со строки:
```yaml
command: [ "sh", "-c", "sleep 1h" ]
```
Запуск пода из манифеста:
```bash
$ kubectl apply -f example-security-context.yml
$ kubectl get pods -o wide
NAME                    READY   STATUS    RESTARTS   AGE   IP            NODE    NOMINATED NODE   READINESS GATES
14.2-netology-vault     1/1     Running   0          29d   10.233.96.8   node2   <none>           <none>
security-context-demo   1/1     Running   47         47h   10.233.92.8   node3   <none>           <none>
```
Вход в контейнер и проверка:
```bash
$ kubectl exec -it security-context-demo -- bash
bash-5.1$ id
uid=1000 gid=3000 groups=3000
bash-5.1$ whoami
whoami: cannot find name for user ID 1000
```
То есть применены параметры пользователя и группы (однако таких параметров нет в среде контейнера)