# Домашнее задание к занятию "14.1 Создание и использование секретов"

## Задача 1: Работа с секретами через утилиту kubectl в установленном minikube.

Для своей работы я использовал уже имеющийся работающий кластер из трёх нод.

1. Как создать секрет?

> openssl genrsa -out cert.key 4096
openssl req -x509 -new -key cert.key -days 3650 -out cert.crt \
-subj '/C=RU/ST=Moscow/L=Moscow/CN=server.local'
kubectl create secret tls domain-cert --cert=certs/cert.crt --key=certs/cert.key  
>
### Решение

Создаю папку в своём рабочем каталоге:

```bash
$ mkdir -p certs
$ cd certs/
$ openssl genrsa -out cert.key 4096
Generating RSA private key, 4096 bit long modulus (2 primes)
...........................................................................................++++
........................................................................++++
e is 65537 (0x010001)
$ ll
total 12
drwxr-xr-x 2 alexey alexey 4096 Nov 14 23:49 ./
drwxr-xr-x 3 alexey alexey 4096 Nov 14 23:49 ../
-rw------- 1 alexey alexey 3243 Nov 14 23:49 cert.key
openssl req -x509 -new -key cert.key -days 3650 -out cert.crt \
-subj '/C=RU/ST=Moscow/L=Moscow/CN=server.local'
$ ll
total 16
drwxr-xr-x 2 alexey alexey 4096 Nov 14 23:51 ./
drwxr-xr-x 3 alexey alexey 4096 Nov 14 23:49 ../
-rw-r--r-- 1 alexey alexey 1944 Nov 14 23:51 cert.crt
-rw------- 1 alexey alexey 3243 Nov 14 23:49 cert.key
$ kubectl create secret tls domain-cert --cert=certs/cert.crt --key=certs/cert.key
secret/domain-cert created
```

2. Посмотрим, что теперь есть в кластере:

### Решение

```bash
$ kubectl get secrets
NAME                             TYPE                                  DATA   AGE
default-token-5qqcl              kubernetes.io/service-account-token   3      21d
domain-cert                      kubernetes.io/tls                     2      47s
my-chart-token-vmvv5             kubernetes.io/service-account-token   3      18d
sh.helm.release.v1.my-chart.v1   helm.sh/release.v1                    1      18d
```

3. Как просмотреть секрет?

### Решение

```bash
$ kubectl get secret domain-cert
NAME          TYPE                DATA   AGE
domain-cert   kubernetes.io/tls   2      5m18s
$ kubectl describe secret domain-cert
Name:         domain-cert
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1944 bytes
tls.key:  3243 bytes
```

4. Как получить информацию в формате YAML и/или JSON?

*Я сократил вывод команд, чтобы не загромождать экран.*

### Решение

```bash
$ kubectl get secret domain-cert -o yaml
apiVersion: v1
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tL...S0VZLS0tLS0K
kind: Secret
metadata:
  creationTimestamp: "2021-11-14T20:53:16Z"
  name: domain-cert
  namespace: default
  resourceVersion: "3260931"
  uid: 16522475-451b-44a7-b355-718148def253
type: kubernetes.io/tls

$ kubectl get secret domain-cert -o json
{
    "apiVersion": "v1",
    "data": {
        "tls.crt": "LS0tLS1CRUdJTiBDRVJUSUZ...FLS0tLS0K",
        "tls.key": "LS0tLS1CRUdJTiBSU0EgUFJJ...gS0VZLS0tLS0K"
    },
    "kind": "Secret",
    "metadata": {
        "creationTimestamp": "2021-11-14T20:53:16Z",
        "name": "domain-cert",
        "namespace": "default",
        "resourceVersion": "3260931",
        "uid": "16522475-451b-44a7-b355-718148def253"
    },
    "type": "kubernetes.io/tls"
}
```

5. Как выгрузить секрет и сохранить его в файл?

### Решение

```bash
$ kubectl get secrets -o json > secrets.json
$ kubectl get secret domain-cert -o yaml > domain-cert.yml
$ ll
total 52
drwxr-xr-x 2 alexey alexey  4096 Nov 15 00:06 ./
drwxr-xr-x 3 alexey alexey  4096 Nov 14 23:49 ../
-rw-r--r-- 1 alexey alexey  1944 Nov 14 23:51 cert.crt
-rw------- 1 alexey alexey  3243 Nov 14 23:49 cert.key
-rw-r--r-- 1 alexey alexey  7166 Nov 15 00:06 domain-cert.yml
-rw-r--r-- 1 alexey alexey 28311 Nov 15 00:05 secrets.json
```

6. Как удалить секрет?

### Решение

```bash
$ kubectl delete secret domain-cert
secret "domain-cert" deleted
$ kubectl get secret
NAME                             TYPE                                  DATA   AGE
default-token-5qqcl              kubernetes.io/service-account-token   3      22d
my-chart-token-vmvv5             kubernetes.io/service-account-token   3      18d
sh.helm.release.v1.my-chart.v1   helm.sh/release.v1                    1      18d
```
7. Как загрузить секрет из файла?

### Решение

```bash
$ kubectl apply -f domain-cert.yml
secret/domain-cert created
$ kubectl get secret
NAME                             TYPE                                  DATA   AGE
default-token-5qqcl              kubernetes.io/service-account-token   3      22d
domain-cert                      kubernetes.io/tls                     2      19s
my-chart-token-vmvv5             kubernetes.io/service-account-token   3      18d
sh.helm.release.v1.my-chart.v1   helm.sh/release.v1                    1      18d
```
