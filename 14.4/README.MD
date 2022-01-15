# Домашнее задание к занятию "14.4 Сервис-аккаунты"

## Задача 1: Работа с сервис-аккаунтами через утилиту kubectl в установленном minikube

### Как создать сервис-аккаунт?

```bash
$ kubectl create serviceaccount netology
serviceaccount/netology created
```
### Как просмотреть список сервис-акаунтов?

```bash
$ kubectl get serviceaccounts
NAME       SECRETS   AGE
default    1         42d
netology   1         4m42s
$ kubectl get serviceaccount
NAME       SECRETS   AGE
default    1         42d
netology   1         5m
```

### Как получить информацию в формате YAML и/или JSON?

```yaml
$ kubectl get serviceaccount netology -o yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2021-12-05T17:25:26Z"
  name: netology
  namespace: default
  resourceVersion: "6291399"
  uid: 0b25acf9-e0f5-4eaf-bdd3-096df9eb5923
secrets:
- name: netology-token-k97d6
```
```json
$ kubectl get serviceaccount default -o json
{
    "apiVersion": "v1",
    "kind": "ServiceAccount",
    "metadata": {
        "creationTimestamp": "2021-10-23T21:07:51Z",
        "name": "default",
        "namespace": "default",
        "resourceVersion": "406",
        "uid": "9cec2045-3134-41e1-a7a5-bcbc66598ddc"
    },
    "secrets": [
        {
            "name": "default-token-5qqcl"
        }
    ]
}
```
### Как выгрузить сервис-акаунты и сохранить его в файл?

```bash
$ kubectl get serviceaccounts -o json > serviceaccounts.json
$ kubectl get serviceaccount netology -o yaml > netology.yml
$ ll
total 20
drwxr-xr-x  2 alexey alexey 4096 Dec  5 21:45 ./
drwxr-xr-x 19 alexey alexey 4096 Dec  5 20:22 ../
-rw-r--r--  1 alexey alexey 1850 Dec  5 21:45 README.MD
-rw-r--r--  1 alexey alexey  239 Dec  5 21:46 netology.yml
-rw-r--r--  1 alexey alexey 1147 Dec  5 21:46 serviceaccounts.json
```

### Как удалить сервис-акаунт?

```bash
$ kubectl delete serviceaccount netology
serviceaccount "netology" deleted
```

### Как загрузить сервис-акаунт из файла?

```bash
$ kubectl apply -f netology.yml
serviceaccount/netology created
$ kubectl get serviceaccounts
NAME       SECRETS   AGE
default    1         42d
netology   2         2m16s

```
