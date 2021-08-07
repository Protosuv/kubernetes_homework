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


