# Домашнее задание к занятию "14.3 Карты конфигураций"

## Задача 1: Работа с картами конфигураций через утилиту kubectl в установленном minikube

### Как создать карту конфигураций?
_Работа осуществляется с кластером из 3х нод в DigitalOcean._
```bash
_$ kubectl create configmap nginx-config --from-file=nginx.conf
configmap/nginx-config created
$ kubectl create configmap domain --from-literal=name=netology.ru
configmap/domain created
```

### Как просмотреть список карт конфигураций?

```bash
$ kubectl get configmaps 
NAME               DATA   AGE
domain             1      64s
kube-root-ca.crt   1      33d
nginx-config       1      3m36s
$ kubectl get configmap
NAME               DATA   AGE
domain             1      96s
kube-root-ca.crt   1      33d
nginx-config       1      4m8s
```

### Как просмотреть карту конфигурации?

```bash
$ kubectl get configmap nginx-config
NAME           DATA   AGE
nginx-config   1      5m
$ kubectl describe configmap domain
Name:         domain
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
name:
----
netology.ru

BinaryData
====

Events:  <none>
```

### Как получить информацию в формате YAML и/или JSON?

```yml
$ kubectl get configmap nginx-config -o yaml
apiVersion: v1
data:
  nginx.conf: |-
    daemon            off;
    worker_processes  2;
    user              www-data;

    events {
        use           epoll;
        worker_connections  128;
    }

    error_log         logs/error.log info;

    http {
        server_tokens off;
        include       mime.types;
        charset       utf-8;

        access_log    logs/access.log  combined;

        server {
            server_name   localhost;
            listen        127.0.0.1:80;

            error_page    500 502 503 504  /50x.html;

            location      / {
                root      html;
            }

        }

    }
kind: ConfigMap
metadata:
  creationTimestamp: "2021-11-25T21:31:20Z"
  name: nginx-config
  namespace: default
  resourceVersion: "4863240"
  uid: d8e2480f-e0b4-4050-a715-54981efbb3a6
```
```json
$ kubectl get configmap domain -o json
{
    "apiVersion": "v1",
    "data": {
        "name": "netology.ru"
    },
    "kind": "ConfigMap",
    "metadata": {
        "creationTimestamp": "2021-11-25T21:33:52Z",
        "name": "domain",
        "namespace": "default",
        "resourceVersion": "4863496",
        "uid": "84bfa119-0095-4cb2-aa0e-274d1b13e0e9"
    }
}
```

### Как выгрузить карту конфигурации и сохранить его в файл?

```bash
$ kubectl get configmaps -o json > configmaps.json
$ ll
total 20
drwxr-xr-x  2 alexey alexey 4096 Nov 26 00:40 ./
drwxr-xr-x 18 alexey alexey 4096 Nov 26 00:25 ../
-rw-r--r--  1 alexey alexey 2882 Nov 26 00:40 README.MD
-rw-r--r--  1 alexey alexey 3109 Nov 26 00:40 configmaps.json
-rw-r--r--  1 alexey alexey  518 Nov 26 00:30 nginx.conf
```
```json
$ cat configmaps.json 
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "v1",
            "data": {
                "name": "netology.ru"
            },
            "kind": "ConfigMap",
            "metadata": {
                "creationTimestamp": "2021-11-25T21:33:52Z",
                "name": "domain",
                "namespace": "default",
                "resourceVersion": "4863496",
                "uid": "84bfa119-0095-4cb2-aa0e-274d1b13e0e9"
            }
        },...
```
```yml
$ kubectl get configmap nginx-config -o yaml > nginx-config.yml
$ cat nginx-config.yml 
apiVersion: v1
data:
  nginx.conf: |-
    daemon            off;
    worker_processes  2;
    user              www-data;

    events {
        use           epoll;
        worker_connections  128;
    }

    error_log         logs/error.log info;

    http {
        server_tokens off;
        include       mime.types;
        charset       utf-8;

        access_log    logs/access.log  combined;

        server {
            server_name   localhost;
            listen        127.0.0.1:80;

            error_page    500 502 503 504  /50x.html;

            location      / {
                root      html;
            }

        }

    }
kind: ConfigMap
metadata:
  creationTimestamp: "2021-11-25T21:31:20Z"
  name: nginx-config
  namespace: default
  resourceVersion: "4863240"
  uid: d8e2480f-e0b4-4050-a715-54981efbb3a6
```

### Как удалить карту конфигурации?

```bash
$ kubectl delete configmap nginx-config
configmap "nginx-config" deleted
```

### Как загрузить карту конфигурации из файла?

```bash
$ kubectl apply -f nginx-config.yml
configmap/nginx-config created
$ kubectl get configmap nginx-config
NAME           DATA   AGE
nginx-config   1      26s
```

## Задача 2 (*): Работа с картами конфигураций внутри модуля
Для работы были найдены примеры в которых в контейнер nginx монтируется nginx.conf файл из configmap, причём поды формируются при помощи deployment. Для работы был выбран неймспейс prod. Для его формирования в кластере, я взял уже готовый манифест, который использовался в прошлых ДЗ.
1. Первоначально был создан неймспейс prod в кластере, для размещения там configmap и собственно подов.

```bash
$ kubectl apply -f ns-prod.yaml
namespace/prod created
```

2. Далее в этом неймспейсе я создал configmap:

```bash
$ kubectl apply -f nginx-config.yml
configmap/nginx-conf created
$ kubectl get configmap -n prod
NAME               DATA   AGE
kube-root-ca.crt   1      23h
nginx-conf         1      14s
```

3. На этом этапе можно создать deployment из манифеста:

```bash
$ kubectl apply -f myapp.yaml
deployment.apps/nginx created
$ kubectl get deploy -n prod
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   1/1     1            1           9s
$ kubectl get pods -n prod
NAME                     READY   STATUS    RESTARTS   AGE
nginx-5668b5dfbb-jmb9r   1/1     Running   0          15s
```

4. Видно что развёртывание готово, под также активен, можно посмотреть, что внутри:

```bash
$ kubectl exec -n prod nginx-5668b5dfbb-jmb9r -i -t -- bash -il
root@nginx-5668b5dfbb-jmb9r:/# cat /etc/nginx/nginx.conf
user nginx;
worker_processes  1;
events {
  worker_connections  10240;
}
http {
  server {
      listen       80;
      server_name  localhost;
      location / {
        root   /usr/share/nginx/html; #Change this line
        index  index.html index.htm;
    }
  }
}
```

То есть мы видим содержимое файла nginx.conf из манифеста, которым создавался configmap.