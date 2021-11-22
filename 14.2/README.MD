# Домашнее задание к занятию "14.2 Синхронизация секретов с внешними сервисами. Vault"

## 1. Задача 1: Работа с модулем Vault

>Запустить модуль Vault конфигураций через утилиту kubectl в установленном minikube

> ``` kubectl apply -f 14.2/vault-pod.yml ```

### Решение:
_Технической возможности использования minikube на момент выполнения работы не было, поэтому работа осуществлялась на базе 3-х нодового кластера в DigitalOcean._
```bash
$ kubectl apply -f vault-pod.yml
pod/14.2-netology-vault created
```
Посмотрим на под, который должен был создаться в кластере:
```bash
$ kubectl get pods -o wide
NAME                  READY   STATUS    RESTARTS   AGE   IP            NODE    NOMINATED NODE   READINESS GATES
14.2-netology-vault   1/1     Running   0          16s   10.233.96.8   node2   <none>           <none>
```
В системе отсутствовала команда jq, поэтому я установил её:
```bash
$ sudo apt install jq
```
В принципе IP адрес пода уже стал известен в процессе запроса подов в кластере и использовании ключа -o wide. Выполняем команду и запрашиваем данные пода:
```bash
$ kubectl get pod 14.2-netology-vault -o json | jq -c '.status.podIPs'
[{"ip":"10.233.96.8"}]
```

>Запустить второй модуль для использования в качестве клиента

> ``` bash kubectl run -i --tty fedora --image=fedora --restart=Never -- sh ```

### Решение:

```bash
$ kubectl run -i --tty fedora --image=fedora --restart=Never -- bash
If you don't see a command prompt, try pressing enter.
[root@fedora /]#
[root@fedora /]# dnf -y install pip
Complete!
[root@fedora /]# pip install hvac
Collecting hvac
...
Installing collected packages: urllib3, idna, charset-normalizer, certifi, six, requests, hvac
Successfully installed certifi-2021.10.8 charset-normalizer-2.0.7 hvac-0.11.2 idna-3.3 requests-2.26.0 six-1.16.0 urllib3-1.26.7
```

> Запустить интепретатор Python и выполнить следующий код, предварительно поменяв IP и токен.
>
Выполняем действия в консоли дополнительного пода:

```python
[root@fedora /]# python3
Python 3.10.0 (default, Oct  4 2021, 00:00:00) [GCC 11.2.1 20210728 (Red Hat 11.2.1-1)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> 
>>> import hvac
>>> client = hvac.Client(
... url='http://10.233.96.8:8200',
... token='Z9NyON0EGnjS'
... )
>>> client.is_authenticated()
True
>>> # Пишем секрет
>>> client.secrets.kv.v2.create_or_update_secret(
...     path='hvac',
...     secret=dict(netology='letitsnow'),
... )
{'request_id': '710100ce-b2d1-7422-e587-2e248c886f37', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'created_time': '2021-11-22T22:04:24.561832503Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 1}, 'wrap_info': None, 'warnings': None, 'auth': None}
# Читаем секрет
client.secrets.kv.v2.read_secret_version(
    path='hvac',
)
{'request_id': '6286c436-8f0d-0b28-f0a5-b88474009cb3', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'data': {'netology': 'letitsnow'}, 'metadata': {'created_time': '2021-11-22T22:04:24.561832503Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 1}}, 'wrap_info': None, 'warnings': None, 'auth': None}
>>> quit
```
Как видно, в процессе выполнения команды, секрет был успешно считан.