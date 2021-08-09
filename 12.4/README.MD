# Домашнее задание к занятию "12.4 Развертывание кластера на собственных серверах, лекция 2"
1. Для работы было решено использовать инструмент Vagrant, для быстрой подготовки 5 штук ВМ в Virtualbox.  
2. В качестве дистрибутива был выбран Ubuntu 20.04.  
3. Умолчания:  
   - мастер нода использует 2 ядра процессора и 2 Гб ОЗУ;  
   - рабочие ноды 1-4 используют 1 ядро процессора и 1 Гб ОЗУ;  
   - на каждую ВМ передаётся ключ SSH с хостовой машины, чтобы иметь возможность подключения по ключу и использовать Ansible плейбуки (использование vagrant ssh также возможно);  
4. Для запуска этих ВМ используется [Vagrantfile](https://github.com/Protosuv/kubernetes_homework/tree/master/12.4/vagrant/Vagrantfile "Vagrantfile").  
После запуска, система сообщает о 5 запущенных ВМ:  
```bash
$ (master)vagrant status 
Current machine states:

master                    running (virtualbox)
node1                     running (virtualbox)
node2                     running (virtualbox)
node3                     running (virtualbox)
node4                     running (virtualbox)
```
5. После этого, можно подготовить файл инвертаря, причём сделать это автоматически по [инструкции](https://github.com/kubernetes-sigs/kubespray "инструкции") на сайте:
```bash
$ declare -a IPS=(192.168.10.21 192.168.10.22 192.168.10.23 192.168.10.24 192.168.10.25)
$ CONFIG_FILE=inventory/kube-test/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
DEBUG: Adding group all
DEBUG: Adding group kube_control_plane
DEBUG: Adding group kube_node
DEBUG: Adding group etcd
DEBUG: Adding group k8s_cluster
DEBUG: Adding group calico_rr
DEBUG: adding host node1 to group all
....
```
Затем было проведено ревью получившегося файла hosts.yaml, в котором etcd был оставлен только на первой ноде (как и control plane).  
Итоговый инвентарь находится в [папке](https://github.com/Protosuv/kubernetes_homework/tree/master/12.4/inventory/kube-test).  
6. Согласно задачи, нам требуется использовать в качестве container runtime - containerd. Для чего мы вносим правки в нужные файлы согласно [статьи](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/containerd.md "официальная статья").  
7. Затем производится установка k8s на запущенные ВМ (команду пришлось подбирать опытным путём, из-за выпадения в ошибку таски):
```bash
$ ansible-playbook -i inventory/kube-test/hosts.yaml --become --become-user=root --become-method sudo cluster.yml -u vagrant
```
В какой-то момент произошла ошибка, в которой было указано, что недостаточно ОЗУ на нодах.В связи с этим, было решено увеличить объём ОЗУ на рабочих нодах до 2Гб.  
Установка продолжилась корректно, но далее завершилась, из-за исчерпания свободного места на хостовой системе, где хранятся диски ВМ от Virtualbox. Увеличить место технически у меня не удастся.


