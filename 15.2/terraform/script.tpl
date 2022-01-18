#!/bin/bash
sudo yum install httpd -y
sudo service httpd start

sudo wget https://${url}/${file} -P /var/www/html/
sudo touch /var/www/html/index.html
sudo chown centos /var/www/html/index.html
sudo echo "<html><h1>Netology: Alexey Suvorov homework</h1><h2>Hello, site hostname is: $(hostname)</h2><div><img src='${file}'></div></html>" > /var/www/html/index.html