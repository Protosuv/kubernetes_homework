# Домашнее задание к занятию "12.5 Сетевые решения CNI"
1. От предыдущего задания остался настроенный кластер в Digital Ocean. Решено использовать его, причём в момент его развёртывания уже был выбран CNI Calico. Таким образом, потребуется развернуть в кластере тестовое приложение и организовать к нему доступ извне.
2. Для начала потребуется развернуть в новом кластере приложение Hello word. Воспользуемся инструкцией от [minikube](https://kubernetes.io/docs/tutorials/_print/#pg-5e3051fff9e84735871d9fb5e7b93f33 "minikube"), где показано как развернуть это приложение в minikube, а также такой [инструкцией](https://kubernetes.io/docs/tasks/run-application/run-stateless-application-deployment/) для создания yaml [файла](https://github.com/Protosuv/kubernetes_homework/tree/master/12.5/hello.yaml), который создаст развёртывание. Применение файла:
```bash
$ kubectl create -f hello.yaml
deployment.apps/hello-deployment created
```
Проверяем состояние:
```bash
$ kubectl get deployments
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
hello-deployment   2/2     2            2           13s
$ kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
hello-deployment-bcb4c7f95-gf77p   1/1     Running   0          96s
hello-deployment-bcb4c7f95-rftwx   1/1     Running   0          96s
$ kubectl describe pod hello-deployment-bcb4c7f95-gf77p | grep node
Node:         node3/Ext IP node3
  Normal  Scheduled  3m7s   default-scheduler  Successfully assigned default/hello-deployment-bcb4c7f95-gf77p to node3
$ kubectl describe pod hello-deployment-bcb4c7f95-rftwx | grep node
Node:         node5/Ext IP node5
  Normal  Scheduled  3m25s  default-scheduler  Successfully assigned default/hello-deployment-bcb4c7f95-rftwx to node5
```
Видно, что scheduler назначил поды на 3 и 5 ноды кластера.
Аналогично можно узнать на каких нодах разместилось приложение командой:
```bash
$ (master)kubectl get pods -o=wide
NAME                                READY   STATUS    RESTARTS   AGE   IP            NODE    NOMINATED NODE   READINESS GATES
hello-deployment-6f8fbf9bb7-6n7j6   1/1     Running   0          19m   10.233.70.7   node5   <none>          <none>
hello-deployment-6f8fbf9bb7-bkpxc   1/1     Running   0          19m   10.233.92.7   node3   <none>          <none>
```  
Увеличение количества реплик достигается командой:
```bash
$ kubectl scale --replicas=4 deployment hello-deployment
deployment.apps/hello-deployment scaled
$ kubectl get deployments
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
hello-deployment   4/4     4            4           13m
```
3. Теперь необходимо сделать приложение доступным извне. Для этого создаётся сервис. Для удобства также делается yaml [файл](https://github.com/Protosuv/kubernetes_homework/tree/master/12.5/hello-svc.yaml)
```bash
$ kubectl create -f hello-svc.yaml
service/hello created
$ kubectl get services
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
hello-svc    ClusterIP   10.233.13.39   <none>        8080/TCP   7m37s
kubernetes   ClusterIP   10.233.0.1     <none>        443/TCP    47h
```
Первоначально можно уже попробовать обратиться по адресу сервиса находясь на управляющей ноде:
```bash
root@node1:~# curl 10.233.13.39:8080
CLIENT VALUES:
client_address=10.233.90.0
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://10.233.13.39:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=10.233.13.39:8080
user-agent=curl/7.68.0
BODY:
-no body in request-
```
Видно, что всё работает. Причём, если вызвать лог любого пода, то при обращении можно заметить, что на него попадает не каждый запрос, а они распределяются по всем подам. Например, в случае уменьшения развёртывания до 2-х подов, на каждое приложение попадает каждый второй запрос:
```bash
$ (master)kubectl logs hello-deployment-6f8fbf9bb7-6n7j6 hello -f
10.233.90.0 - - [11/Aug/2021:19:40:27 +0000] "GET / HTTP/1.1" 200 392 "-" "curl/7.68.0"
10.233.90.0 - - [11/Aug/2021:19:50:41 +0000] "GET / HTTP/1.1" 200 392 "-" "curl/7.68.0"
```
Для того, чтобы иметь возможность попасть на наше приложение снаружи (из внешней сети), то тип сервиса как ClusterIP уже не подходит. В файл описания сервиса вносим правки и указываем тип NodePort, удаляем старый сервис и применяем новый:
```bash
$ (master)kubectl get svc -o wide
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE   SELECTOR
hello-svc    NodePort    10.233.42.235   <none>        80:30559/TCP   66s   app=hello
kubernetes   ClusterIP   10.233.0.1      <none>        443/TCP        2d    <none>
```
Видно, что система присвоила порт 30559, по которому при входе на внешний адрес любой ноды, удаётся попасть на приложение.  

4. Работаем с утилитой calicoctl, для чего производится её установка по [инструкции](https://docs.projectcalico.org/getting-started/clis/calicoctl/install).  
Для удобства, утилита была добавлена в PATH в .bashrc профиля пользователя.  
Просмотр нод в кластере, пула адресов и профиль:
```bash
$ calicoctl get nodes
NAME    
node1   
node2   
node3   
node4   
node5
$ calicoctl get ippool -o wide
NAME           CIDR             NAT    IPIPMODE   VXLANMODE   DISABLED   SELECTOR   
default-pool   10.233.64.0/18   true   Always     Never       false      all()
$ (master)calicoctl get profile
NAME                                                 
projectcalico-default-allow                          
kns.default                                          
kns.kube-node-lease                                  
kns.kube-public                                      
kns.kube-system                                      
ksa.default.default                                  
...
```






