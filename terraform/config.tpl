#!/bin/bash
sudo apt-get update
sudo apt-get -y install apache2 mysql-client php7.0 libapache2-mod-php7.0 wordpress
sudo rm -rf /var/www/html
sudo ln -s /usr/share/wordpress /var/www/html
sudo service apache2 restart
sudo echo -e "<?php \ndefine(\"DB_NAME\", \"${db_name}\");\n \
                    define(\"DB_USER\", \"${db_user}\");\n \
                    define(\"DB_PASSWORD\", \"${db_password}\");\n \
                    define(\"DB_HOST\", \"${db_host}\");\n \
                    define(\"DB_CHARSET\", \"utf8\");\n ?>" >> /etc/wordpress/config-default.php
