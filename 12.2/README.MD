# Домашнее задание к занятию "12.2 Команды для работы с Kubernetes"

## Задание 1:
1. Запуск раннее установленного кластера на базе minikube.
```bash
$ minikube start --vm-driver=virtualbox
```
2. Проверка состояния:
```bash
$ minikube status
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```
3. Удаление старого развёртывания из одной реплики:
```bash
$ kubectl delete deployment hello-node
deployment.apps "hello-node" deleted
```
4. Создание нового развёртывания из двух реплик и проверка состояния:
```bash
$ kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4 --replicas=2
deployment.apps/hello-node created

$ kubectl get deployment
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   2/2     2            2           72s

$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-7567d9fdc9-45qsq   1/1     Running   0          44s
hello-node-7567d9fdc9-x5m69   1/1     Running   0          44s
```
## Задание 2:
5. Создание нового пользователя с ограниченными правами:
```bash
$ mkdir -p cert && cd cert
$ openssl genrsa -out user1.key 2048
Generating RSA private key, 2048 bit long modulus (2 primes)
..............................+++++
..............+++++
e is 65537 (0x010001)
$ openssl req -new -key user1.key -out user1.csr -subj "/CN=user1/O=group1"
$ openssl x509 -req -in user1.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out user1.crt -days 500
Signature ok
subject=C = RU, ST = Ru, O = Internet Widgits Pty Ltd
Getting CA Private Key
```
6. Добавление пользователя:
```bash
$ kubectl config set-credentials user1 --client-certificate=user1.crt --client-key=user1.key
User "user1" set.

$ kubectl config set-context user1-context --cluster=minikube --user=user1
Context "user1-context" created.

$ kubectl config view
....
- name: user1
  user:
    client-certificate: ~/Kubernetes/12.2/cert/user1.crt
    client-key: ~/Kubernetes/12.2/cert/user1.key

```
7. Указываем права для пользователя:
```bash
$ kubectl apply -f role.yaml
role.rbac.authorization.k8s.io/pod-reader created

$ kubectl apply -f role-binding.yaml
rolebinding.rbac.authorization.k8s.io/read-pods created

$ kubectl get roles
NAME         CREATED AT
pod-reader   2021-07-28T21:09:48Z

$ kubectl get rolebindings
NAME        ROLE              AGE
read-pods   Role/pod-reader   74s

$ kubectl create namespace ns-test
Error from server (Forbidden): namespaces is forbidden: User "user1" cannot create resource "namespaces" in API group "" at the cluster scope

kubectl get pods

```
https://medium.com/@HoussemDellai/rbac-with-kubernetes-in-minikube-4deed658ea7b
## Задание 3:
8. Увеличиваем количество реплик в нашем развёртывании и проверяем что получилось:
```bash
$ kubectl scale --replicas=5 deployment hello-node
deployment.apps/hello-node scaled
```
9. Видно, что количество стало 5 штук, причём две работали давно (видно по времени), три - новые.
```bash
$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-7567d9fdc9-45qsq   1/1     Running   0          10m
hello-node-7567d9fdc9-7w8kf   1/1     Running   0          17s
hello-node-7567d9fdc9-ctwd8   1/1     Running   0          17s
hello-node-7567d9fdc9-wghsd   1/1     Running   0          17s
hello-node-7567d9fdc9-x5m69   1/1     Running   0          10m
```
