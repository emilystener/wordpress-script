#!/bin/bash

super_secure_password="$RANDOM-$RANDOM-$RANDOM-$RANDOM"
echo "${super_secure_password}" > /root/super_secure_password

/bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=2048
/sbin/mkswap /var/swap.1
/sbin/swapon /var/swap.1

yum -y install git httpd24 php56 php56-mysqlnd php56-mcrypt php56-mbstring mysql56-server
git clone https://github.com/maludwig/bashrc
cd bashrc
./install 
. /etc/bashrc.extensions/main

service httpd start
service mysqld start
mysqladmin -u root password "${super_secure_password}"
echo "CREATE USER 'wordpress'@'localhost' IDENTIFIED WITH mysql_native_password;GRANT USAGE ON *.* TO 'wordpress'@'localhost' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;SET PASSWORD FOR 'wordpress'@'localhost' = PASSWORD('${super_secure_password}');CREATE DATABASE IF NOT EXISTS wordpress;GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';" | mysql -uroot -p"${super_secure_password}"

cd /var/www/html/
wget https://wordpress.org/latest.tar.gz
tar -xvf latest.tar.gz 
rm -f latest.tar.gz 
mv wordpress/* ./
rm -rf wordpress/

wget https://files.phpmyadmin.net/phpMyAdmin/4.6.0/phpMyAdmin-4.6.0-english.tar.gz
tar -xvf phpMyAdmin-4.6.0-english.tar.gz 
mv phpMyAdmin-4.6.0-english pma
rm -f phpMyAdmin-4.6.0-english.tar.gz 
cd pma
sed -r 's/.cfg..blowfish_secret.. = ..;/$'"cfg['blowfish_secret'] = '${super_secure_password}';/" config.sample.inc.php > config.inc.php

chown -R apache:apache /var/www/html/

cat /root/super_secure_password