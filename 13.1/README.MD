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
$ kubectl apply -f back-front-dep.yaml 
deployment.apps/backend-frontend-dep created
$ kubectl get pods -n test -o wide
NAME                                    READY   STATUS    RESTARTS   AGE   IP             NODE    NOMINATED NODE   READINESS GATES
backend-frontend-dep-7d9999bffd-mx2sz   2/2     Running   0          14s   10.233.96.21   node2   <none>           <none>
postgresql-db-0                         1/1     Running   0          11m   10.233.96.20   node2   <none>           <none>
```
Заводим в кластере новый сервис, чтобы можно было получить доступ к фронту снаружи кластера:
```bash
$ kubectl apply -f front-svc.yaml 
service/frontend created

$ kubectl get svc -n test -o wide
NAME       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE     SELECTOR
db         ClusterIP   10.233.48.109   <none>        5432/TCP         4m39s   app=postgresql-db
frontend   NodePort    10.233.32.204   <none>        8080:30988/TCP   3s      run=backfront
```
Все файлы находятся по [пути](https://github.com/Protosuv/kubernetes_homework/tree/master/13.1/13-kubernetes-config/task1 "путь").  
Теперь по внешнему адресу сервера по указанному порту будет доступно наше приложение:  
![Страница приложения](https://github.com/Protosuv/kubernetes_homework/blob/master/13.1/13-kubernetes-config/kuber_13.1_1.png "Страница приложения")

2. В этом задании мы используем наработки из предыдущего задания и разделим компоненты приложения по разным развёртываниям. В частности, в нашем случае мы разносим фронтенд и бекенд, а сервис для СУБД у нас уже имеется и его можно не трогать.  
Требуется создать файл с развёртыванием для бекенда и добавить для него сервис.  
Последовательность действий аналогичная предшествующему заданию:  
  - разворачиваем неймспейс
  - разворачиваем PV и PVC для СУБД и разворачиваем СУБД с сервисом
  - разворачиваем фронтенд и бекенд и их сервисы
  - тестируем работу
```bash
$ kubectl apply -f db-pv.yaml
persistentvolume/postgresql-pv-volume-prod created
persistentvolumeclaim/postgresql-pv-claim-prod created
$ kubectl get pv -o wide
NAME                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                           STORAGECLASS   REASON   AGE   VOLUMEMODE
postgresql-pv-volume-prod   10Gi       RWO            Retain           Bound    prod/postgresql-pv-claim-prod   manual                  51s   Filesystem

$ kubectl apply -f db-sts.yaml 
statefulset.apps/postgresql-db created
$ kubectl get sts -n prod -o wide
NAME            READY   AGE   CONTAINERS      IMAGES
postgresql-db   1/1     83s   postgresql-db   postgres:latest

$ kubectl apply -f db-svc.yaml 
service/db created
$ kubectl get svc -n prod -o wide
NAME   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE   SELECTOR
db     ClusterIP   10.233.12.83   <none>        5432/TCP   26s   app=postgresql-db

$ kubectl apply -f back
back-svc.yaml  back.yaml
$ kubectl apply -f back-svc.yaml 
service/backend created
$ kubectl get svc -n prod -o wide
NAME      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE    SELECTOR
backend   ClusterIP   10.233.21.122   <none>        9000/TCP   30s    run=backend
$ kubectl get deploy -n prod -o wide
NAME          READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                    SELECTOR
backend-dep   1/1     1            1           71s   backend      protosuv/backend:latest   run=backend

$ kubectl apply -f front.yaml 
deployment.apps/frontend-dep created
$ kubectl apply -f front-svc.yaml 
service/frontend created
$ kubectl get deploy -n prod -o wide
NAME           READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES                     SELECTOR
backend-dep    1/1     1            1           2m15s   backend      protosuv/backend:latest    run=backend
frontend-dep   1/1     1            1           32s     frontend     protosuv/frontend:latest   run=frontend

$ kubectl get svc -n prod -o wide
NAME       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE     SELECTOR
backend    ClusterIP   10.233.21.122   <none>        9000/TCP         2m23s   run=backend
db         ClusterIP   10.233.12.83    <none>        5432/TCP         3m35s   app=postgresql-db
frontend   NodePort    10.233.54.214   <none>        8000:32091/TCP   48s     run=frontend
```
Все файлы находятся по [пути](https://github.com/Protosuv/kubernetes_homework/tree/master/13.1/13-kubernetes-config/task2 "путь").
Теперь по внешнему адресу сервера по указанному порту будет доступно наше приложение:  
![Страница приложения](https://github.com/Protosuv/kubernetes_homework/blob/master/13.1/13-kubernetes-config/kuber_13.1_2.png "Страница приложения")