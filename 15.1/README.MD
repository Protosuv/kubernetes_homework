# Домашнее задание к занятию "15.1. Организация сети


Для создания всех ресурсов были использованы прошлые наработки и информация из открытых источников и документации.  
Файлы были сгруппированы по разным настройкам, которые в них включены. Для удобства, по итогам ранней практики, я вынес переменные в отдельный файл. Среди них есть переменные указывающие количество инстансов нужного типа, зону, тип дистрибутива и т.д.  
Для работы я выбрал образ Centos7. Для своего удобства я сделал присвоение IP адреса каждому серверу в его сети, чтобы зная его, подключаться к ним.

Итого все файлы были выгружены в [папку](https://github.com/Protosuv/kubernetes_homework/tree/master/15.1/terraform "манифесты").

```bash
$ terraform plan -out plan
```
Из вывода следовало, что будут созданы все нужные ресурсы. Допольнительно я также добавил вывод нужных переменных в файле outputs.tf. После плана и его применения, система мне сообщила внешниt адреса серверов для подключения:

```bash
region = "us-east-2"
server1_public_dns = ""
server1_public_ip = "3.12.164.211"
server2_public_dns = ""
server2_public_ip = "18.216.48.53"
```
Зная адрес, я могу подключаюсь к серверу, используя ключ:
```bash
$ ssh -i laptop.pem centos@3.12.164.211
[centos@ip-172-31-32-5 ~]$ whoami
centos
```
Проверяем доступ к сети интернет и маршрут:
```bash
[centos@ip-172-31-32-5 ~]$ ping mail.ru
PING mail.ru (217.69.139.200) 56(84) bytes of data.
64 bytes from mail.ru (217.69.139.200): icmp_seq=1 ttl=38 time=179 ms
64 bytes from mail.ru (217.69.139.200): icmp_seq=2 ttl=38 time=209 ms
64 bytes from mail.ru (217.69.139.200): icmp_seq=3 ttl=38 time=176 ms
64 bytes from mail.ru (217.69.139.200): icmp_seq=4 ttl=38 time=196 ms
64 bytes from mail.ru (217.69.139.200): icmp_seq=5 ttl=38 time=176 ms

[centos@ip-172-31-32-5 ~]$ traceroute mail.ru
traceroute to mail.ru (94.100.180.201), 30 hops max, 60 byte packets
 1  ec2-52-15-0-49.us-east-2.compute.amazonaws.com (52.15.0.49)  2.245 ms ec2-52-15-0-53.us-east-2.compute.amazonaws.com (52.15.0.53)  1.607 ms ec2-52-15-0-57.us-east-2.compute.amazonaws.com (52.15.0.57)  6.681 ms
 2  100.65.30.160 (100.65.30.160)  5.758 ms 100.65.31.128 (100.65.31.128)  0.948 ms 100.65.31.16 (100.65.31.16)  11.643 ms
 ...
 29  hundredgige0-1-0-6.lontr6.london.opentransit.net (193.251.241.139)  85.457 ms  85.204 ms  85.462 ms
30  ae303-0.ffttr6.frankfurt.opentransit.net (193.251.243.248)  98.493 ms  98.436 ms  98.370 ms
```
Подключение ко второму серверу по внешнему адресу невозможно, о чём можно убедиться:
```bash
$ (master)ssh -i laptop.pem centos@18.216.48.53
ssh: connect to host 18.216.48.53 port 22: Connection timed out
```
Для подключения к серверу, были подготовлены зараннее сгенерированные файлы: сертификат клиента, ключ клиента, корневой сертификат. Для работы я использовал встроенный в Linux Mint 20 клиент. После успешной установки соединения, я просмотрел список адресов и список маршрутов:
```bash
tun0: flags=4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST>  mtu 1500
        inet 10.0.0.162  netmask 255.255.255.224  destination 10.0.0.162
        unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen 100  (UNSPEC)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 134  bytes 25111 (25.1 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
$ ip route
...
72.31.0.0/16 via 10.0.0.161 dev tun0 proto static metric 50
```
То есть видно, что маршрут на сеть в AWS указывает на туннельный интерфейс OpenVPN. Посмотрим пингование инстанса в сети:
```bash
$ ping 172.31.96.5
PING 172.31.96.5 (172.31.96.5) 56(84) bytes of data.
64 bytes from 172.31.96.5: icmp_seq=1 ttl=63 time=171 ms
64 bytes from 172.31.96.5: icmp_seq=2 ttl=63 time=174 ms
64 bytes from 172.31.96.5: icmp_seq=3 ttl=63 time=174 ms
```
Производим подключение к нему по серому IP адресу, который до этого успешно пинговался:
 ```bash
  (master)ssh -i laptop.pem centos@172.31.96.5

[centos@ip-172-31-96-5 ~]$
```
Теперь проверим пингование до внешнего адреса mail.ru в качестве примера:
```bash
[centos@ip-172-31-96-5 ~]$ ping mail.ru
PING mail.ru (217.69.139.200) 56(84) bytes of data.
64 bytes from mail.ru (217.69.139.200): icmp_seq=1 ttl=37 time=171 ms
64 bytes from mail.ru (217.69.139.200): icmp_seq=2 ttl=37 time=170 ms
64 bytes from mail.ru (217.69.139.200): icmp_seq=3 ttl=37 time=170 ms
64 bytes from mail.ru (217.69.139.200): icmp_seq=4 ttl=37 time=170 ms
```
Как видно, пингование работает, следовательно на сервере есть доступ к сети интернет.
