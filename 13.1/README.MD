# Домашнее задание к занятию "13.1 контейнеры, поды, deployment, statefulset, services, endpoints"
1. В задании испоьзуется раннее настроенный кластер из трёх нод: control plane и две worker ноды. Управление кластером осуществляется с рабочего ноутбука, путём переноса конфигурации кластера в папку пользователя.  
В описании задания имеется ошибка, которая заключается в неверной формулировке. Дело в том, что невозможно запустить в одном поде сервисы поднятые при помощи различных инструментов. В частности не запустить поды при помощи развёртывания и в тоже время statefulset.  
Таким образом, фактически требуется запустить три пода в каждом из которых будет по одному контейнеру с сервисом.  
1.1. Первоначально выполняем запуск compose файла и сборку проекта. После первого запуска и остановки, приложение было запущено во второй раз. По портам, указанным в compose файле открылась страница (путь [http://localhost:8000/](http://localhost:8000/)).  
1.2.Затем полученные артефакты в виде двух образов я запушил в свой репозиторий на докерхабе (см. [ссылку](https://hub.docker.com/repositories)). Они понадобятся затем при запуске приложения в кластере.   
Затем, с уже готовыми образами можно формировать манифесты для запуска приложений в кластере.  
1.3. Работаем с подом с СУБД и первоначально создаём место для хранения файлов БД на двух рабочих нодах. 
```bash
$ kubectl apply -f db-pv.yaml
persistentvolume/postgres-pv-volume created
persistentvolumeclaim/postgres-pv-claim created
```
Смотрим, что получилось:  
```bash
$ kubectl get pv -o wide
NAME                 CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                       STORAGECLASS   REASON   AGE   VOLUMEMODE
postgres-pv-volume   10Gi       RWO            Retain           Bound    default/postgres-pv-claim   manual                  56s   Filesystem
$ kubectl get pvc -o wide
NAME                STATUS   VOLUME               CAPACITY   ACCESS MODES   STORAGECLASS   AGE   VOLUMEMODE
postgres-pv-claim   Bound    postgres-pv-volume   10Gi       RWO            manual         80s   Filesystem
```
Поднимаем под с СУБД при помощи stefulset:
```bash
$ kubectl apply -f db-sts.yaml
statefulset.apps/postgresql-db created
$ kubectl get sts -o wide
NAME            READY   AGE   CONTAINERS      IMAGES
postgresql-db   1/1     17s   postgresql-db   postgres:latest
$ kubectl get pods -o wide
NAME              READY   STATUS    RESTARTS   AGE   IP            NODE    NOMINATED NODE   READINESS GATES
postgresql-db-0   1/1     Running   0          96s   10.233.96.6   node2   <none>           <none>
```
Видно, что под с СУБД запустился на второй рабочей ноде.  
Смотрим журнал СУБД (главные записи):
```
$ kubectl logs postgresql-db-0
PostgreSQL init process complete; ready for start up.
...
2021-08-24 21:27:47.452 UTC [1] LOG:  database system is ready to accept connections
```
1.4. Теперь запускаем развёртывание пода с бэкендом:
```bash

