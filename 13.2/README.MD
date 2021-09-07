# Домашнее задание к занятию "13.2. Разделы и монтирование"
1. В задании испоьзуется раннее настроенный кластер из трёх нод: control plane и две worker ноды. Управление кластером осуществляется с рабочего ноутбука.
Все файлы находятся по [пути](https://github.com/Protosuv/kubernetes_homework/tree/master/13.2/ "путь").  
Для выполнения задания 1 был взят манифест от совместного развёртывания backend и frontend. В него были внесены изменения, чтобы оба контейнера пода имели доступ к общей папке.
Запускаем развёртывание:
```bash
$ kubectl apply -f back-front-dep.yaml
deployment.apps/backend-frontend-dep created
$ kubectl get pods -n prod
NAME                                    READY   STATUS    RESTARTS   AGE
backend-frontend-dep-5c856b5578-qgkxg   2/2     Running   0          12s
postgresql-db-0                         1/1     Running   0          4d22h
$ kubectl get deploy -n prod
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
backend-frontend-dep   1/1     1            1           27s
$ kubectl exec -it backend-frontend-dep-5c856b5578-qgkxg frontend -n prod -- bash
Defaulted container "backend" out of: backend, frontend
root@backend-frontend-dep-5c856b5578-qgkxg:/app# ls -la /static/
total 8
$ echo "Test content" >> /static/test.txt
$ kubectl exec -it backend-frontend-dep-5c856b5578-qgkxg backend -n prod -- bash
Defaulted container "backend" out of: backend, frontend
$ cat /static/test.txt
Test content
```
Таким образом видно, что файл был создан в поде в контейнере frontend. Проверка показала наличие файла с нужным содержимым во втором контейнере пода (backend).  

2. Удаляем развёртываение из предыдущего задания, поскольку нам понадобятся два новых отдельных развёртывания. Для проверки нам сгодятся два развёртывания из предыдущей работы, но дополненные PV и PVC.
Проделываем действия по инструкции, чтобы получить NFS сервер:
```bash
$ helm install nfs-server stable/nfs-server-provisioner -n prod
WARNING: This chart is deprecated
NAME: nfs-server
LAST DEPLOYED: Mon Sep  6 23:46:13 2021
NAMESPACE: prod
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The NFS Provisioner service has now been installed.

A storage class named 'nfs' has now been created
and is available to provision dynamic volumes.
$ kubectl get pods -n prod -o wide
NAME                                    READY   STATUS        RESTARTS   AGE     IP             NODE    NOMINATED NODE   READINESS GATES
nfs-server-nfs-server-provisioner-0     1/1     Running       0          2m48s   10.233.90.3    node1   <none>           <none>
postgresql-db-0                         1/1     Running       0          4d23h   10.233.92.10   node3   <none>           <none>
```

Загружаем подготовленные манифесты, начиная с PVC:
```bash
$ kubectl apply -f pvc_nfs.yaml
persistentvolumeclaim/content-claim created
$ kubectl get pvc -n prod -o wide
NAME                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE     VOLUMEMODE
content-claim              Bound    pvc-b8adcb70-3ad1-4de7-b74c-1ef3452309f0   100Mi      RWX            nfs            12s     Filesystem
postgresql-pv-claim-prod   Bound    postgresql-pv-volume-prod                  10Gi       RWO            manual         4d23h   Filesystem
$ kubectl apply -f front.yaml
deployment.apps/frontend-dep created
$ kubectl apply -f back.yaml
deployment.apps/backend-dep created
```
В итоге мы получаем ситуацию, когда поды фронтенд и бекенд не поднимаются. Вот что видно в консоли:
```bash
$ kubectl get pods --all-namespaces -o wide
...
prod   backend-dep-849748c577-77ql6   0/1     ContainerCreating   0          14m   <none>          node2    <none>           <none>
```
В таком состоянии под пребывает бесконечно долго времени. Для понимания, что не так, команда kubectl logs не подходит, поскольку контейнер в поде не поднимается и никаких логов не будет. Для этого подходит команда *kubectl get event -n prod*, которая и проливает свет на ситуацию:
```bash
9m56s       Warning   FailedMount             pod/backend-dep-849748c577-77ql6      MountVolume.SetUp failed for volume "pvc-9ea98a38-cb18-4177-9efb-b12c57367c16" : mount failed: exit status 32.
```
Для решения этой ситуации недостаёт компонента nfs-common на нодах:
```bash
apt install nfs-common
```
Только после этого ситуация разрешается:
```bash
$ kubectl get pods -n prod -o wide
NAME                                  READY   STATUS    RESTARTS   AGE     IP             NODE    NOMINATED NODE   READINESS GATES
backend-dep-849748c577-7q62h          1/1     Running   0          24m     10.233.92.23   node3   <none>           <none>
frontend-dep-5c7777f5fb-q7pdb         1/1     Running   0          7m55s   10.233.96.28   node2   <none>           <none>
nfs-server-nfs-server-provisioner-0   1/1     Running   0          22h     10.233.90.8    node1   <none>           <none>
postgresql-db-0                       1/1     Running   0          22h     10.233.90.6    node1   <none>           <none>
```
Теперь можно проверить обмен информацией между подами:
```bash
$ kubectl exec -it -n prod backend-dep-849748c577-7q62h -- bash
$ cd /static/
$ echo "Test content" >> content.txt
$ cat content.txt
Test content
$ exit
$ kubectl exec -it -n prod frontend-dep-5c7777f5fb-q7pdb -- bash
$ cd /static/
$ cat content.txt
Test content
$ exit
```
Видно, что созданный в поде с бекендом файл, появился в такой же папке в поде с фронтендом.