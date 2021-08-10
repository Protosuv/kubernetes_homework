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
Node:         node3/138.68.74.120
  Normal  Scheduled  3m7s   default-scheduler  Successfully assigned default/hello-deployment-bcb4c7f95-gf77p to node3
$ kubectl describe pod hello-deployment-bcb4c7f95-rftwx | grep node
Node:         node5/138.68.68.236
  Normal  Scheduled  3m25s  default-scheduler  Successfully assigned default/hello-deployment-bcb4c7f95-rftwx to node5
```
Видно, что scheduler назначил поды на 3 и 5 ноды кластера.  
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
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
hello        ClusterIP   10.233.4.207   <none>        80/TCP    13s
kubernetes   ClusterIP   10.233.0.1     <none>        443/TCP   24h
```



