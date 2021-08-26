# Домашнее задание к занятию "13.1 контейнеры, поды, deployment, statefulset, services, endpoints"
1. В задании испоьзуется раннее настроенный кластер из трёх нод: control plane и две worker ноды. Управление кластером осуществляется с рабочего ноутбука, путём переноса конфигурации кластера в папку пользователя.  
В описании задания имеется ошибка, которая заключается в неверной формулировке. Дело в том, что невозможно запустить в одном поде сервисы поднятые при помощи различных инструментов. В частности не запустить поды при помощи развёртывания и в тоже время statefulset.  
Таким образом, фактически требуется запустить три пода в каждом из которых будет по одному контейнеру с сервисом.  
1.1. Первоначально выполняем запуск compose файла и сборку проекта. После первого запуска и остановки, приложение было запущено во второй раз. По портам, указанным в compose файле открылась страница (путь [http://localhost:8000/](http://localhost:8000/)).  
1.2.Затем полученные артефакты в виде двух образов я запушил в свой репозиторий на докерхабе (см. [frontend](https://hub.docker.com/repository/docker/protosuv/frontend) и [backtend](https://hub.docker.com/repository/docker/protosuv/backend)). Они понадобятся затем при запуске приложения в кластере.   
Затем, с уже готовыми образами можно формировать манифесты для запуска приложений в кластере.  
1.3.Создаём тестовый namespace из созданного манифеста:
```bash
$ kubectl apply -f ns-test.yaml 
namespace/test created
$ kubectl get ns
NAME              STATUS   AGE
default           Active   13d
kube-node-lease   Active   13d
kube-public       Active   13d
kube-system       Active   13d
test              Active   10s
```
1.4.Работаем с подом с СУБД и первоначально создаём место для хранения файлов БД на двух рабочих нодах (папки на ФС нод создаём до этого). 
```bash
$ kubectl apply -f db-pv.yaml
persistentvolume/postgres-pv-volume created
persistentvolumeclaim/postgres-pv-claim created
```
Смотрим, что получилось:  
```bash
$ kubectl get pv -n test -o wide
NAME                 CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                       STORAGECLASS   REASON   AGE   VOLUMEMODE
postgres-pv-volume   10Gi       RWO            Retain           Bound    default/postgres-pv-claim   manual                  56s   Filesystem
$ kubectl get pvc -n test -o wide
NAME                STATUS   VOLUME               CAPACITY   ACCESS MODES   STORAGECLASS   AGE   VOLUMEMODE
postgres-pv-claim   Bound    postgres-pv-volume   10Gi       RWO            manual         80s   Filesystem
```
Поднимаем под с СУБД при помощи stefulset:
```bash
$ kubectl apply -f db-sts.yaml
statefulset.apps/postgresql-db created
$ kubectl get sts -n test -o wide
NAME            READY   AGE   CONTAINERS      IMAGES
postgresql-db   1/1     17s   postgresql-db   postgres:latest
$ kubectl get pods -n test -o wide
NAME              READY   STATUS    RESTARTS   AGE   IP            NODE    NOMINATED NODE   READINESS GATES
postgresql-db-0   1/1     Running   0          96s   10.233.96.20   node2   <none>           <none>
```
Видно, что под с СУБД запустился на второй рабочей ноде.  
Смотрим журнал СУБД (главные записи):
```
$ kubectl logs -n test postgresql-db-0
PostgreSQL init process complete; ready for start up.
...
2021-08-24 21:27:47.452 UTC [1] LOG:  database system is ready to accept connections
```
Запускаем сервис для СУБД из его манифеста:
```bash
$ kubectl apply -f db-svc.yaml
service/db created
$ kubectl get svc -n test -o wide
NAME   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE   SELECTOR
db     ClusterIP   10.233.48.109   <none>        5432/TCP   32s   app=postgresql-db
```
1.5. Теперь запускаем развёртывание пода с бэкендом и фронтендом:
```bash
$ (master)kubectl apply -f back-front-dep.yaml 
deployment.apps/backend-frontend-dep created
$ (master)kubectl get pods -n test -o wide
NAME                                    READY   STATUS    RESTARTS   AGE   IP             NODE    NOMINATED NODE   READINESS GATES
backend-frontend-dep-7d9999bffd-mx2sz   2/2     Running   0          14s   10.233.96.21   node2   <none>           <none>
postgresql-db-0                         1/1     Running   0          11m   10.233.96.20   node2   <none>           <none>
```
Заводим в кластере новый сервис, чтобы можно было получить доступ к фронту снаружи кластера:
```bash
$ (master)kubectl apply -f front-svc.yaml 
service/frontend created

$ (master)kubectl get svc -n test -o wide
NAME       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE     SELECTOR
db         ClusterIP   10.233.48.109   <none>        5432/TCP         4m39s   app=postgresql-db
frontend   NodePort    10.233.32.204   <none>        8080:30470/TCP   3s      run=backfront
```


