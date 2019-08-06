#!/bin/bash
sudo apt-get update
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password ${db_password}'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password ${db_password}'
sudo apt-get -y install mysql-server
sudo apt-get -y install mysql-server python-mysqldb
sudo sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
sudo service mysql restart
mysql -p${db_password} -e "create database ${db_name}"
mysql -p${db_password} -e "GRANT ALL PRIVILEGES ON *.* TO '${db_user}'@'%' IDENTIFIED BY '${db_password}'"
