 #!/bin/bash

#The two sites below helped me with my unattended scripts
#Suitecrm -> https://websiteforstudents.com/install-suitecrm-ubuntu-17-04-17-10-apache2-mariadb-php/
#Wordpress -> https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-lamp-on-ubuntu-16-04
#mysql_secure_installation -> https://gist.github.com/Mins/4602864

 PW=Sputnik78**
 MYSQL=nosrebob

echo $PW | sudo apt-get -y update
echo $PW | sudo apt-get -y upgrade
echo $PW | sudo reboot

#Install expect for later usage
echo $PW | sudo apt-get install expect

#Install git for later usage
echo $PW | sudo apt-get install git

#Install apache2 and disable directory listing and enable .htaccess overrides
echo $PW | sudo apt-get install apache2
echo $PW | sudo sed -i "s/Options Indexes FollowSymLinks/Options FollowSymLinks/" /etc/apache2/apache2.conf
echo "<Directory /var/www/html/>
        AllowOverride All
      </Directory>" >> /etc/apache2/apache2.conf

#restart apache
echo $PW | sudo systemctl restart apache2

echo $PW | sudo apt-get install mariadb-server mariadb-client
#Use expect to automate the mysql_secure_installation
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$MYSQL\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

echo "$SECURE_MYSQL"
echo $PW | sudo systemctl restart mariadb.service

#Install php and related modules
echo $PW | sudo apt-get install php php-common php-mbstring php-xmlrpc php-soap php-gd php-xml php-intl php-mysql php-cli php-mcrypt php-ldap php-zip php-curl

#Create database and user with necessary permissions for SuiteCRM and wordpress
echo $PW | mysql -u root -p -e "CREATE DATABASE suitecrm;"
echo $PW | mysql -u root -p -e "CREATE DATABASE wordpress;"

echo $PW | mysql -u root -p -e "CREATE USER 'jbw14a'@'localhost' IDENTIFIED BY 'nosrebob';"

echo $PW | mysql -u root -p -e "GRANT ALL ON suitecrm.* TO 'jbw14a'@'localhost' IDENTIFIED BY 'nosrebob' WITH GRANT OPTION;"
echo $PW | mysql -u root -p -e "GRANT ALL ON wordpress.* TO 'jbw14a'@'localhost' IDENTIFIED BY 'nosrebob' WITH GRANT OPTION;"
echo $PW | mysql -u root -p -e "FLUSH PRIVILEGES;"

#Download latest version of Suitecrm and Wordpress
cd /tmp
git clone https://github.com/salesagility/SuiteCRM.git suitecrm
echo $PW | sudo mv suitecrm /var/www/html/suitecrm

echo $PW | curl -O https://wordpress.org/latest.tar.gz
echo $PW | tar xzvf latest.tar.gz
echo $PW | touch /tmp/wordpress/.htaccess
echo $PW | chmod 660 /tmp/wordpress/.htaccess
echo $PW | cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
echo $PW | mkdir /tmp/wordpress/wp-content/upgrade
echo $PW | sudo cp -a /tmp/wordpress/. /var/www/html
cd ~

#Modify directory permissions to fit apache2 configuration
echo $PW | sudo chown -R www-data:www-data /var/www/html/
echo $PW | sudo chmod -R 755 /var/www/html/

#Modify wp-config to hold database info
echo $PW | sed -i "s/define('DB_NAME', 'database_name_here');/define('DB_NAME', 'wordpress');/g" /var/www/html/wp-config.php
echo $PW | sed -i "s/define('DB_USER', 'username_here');/define('DB_USER', 'root');/g" /var/www/html/wp-config.php
echo $PW | sed -i "s/define('DB_PASSWORD', 'password_here');/define('DB_PASSWORD', 'nosrebob');/g" /var/www/html/wp-config.php
echo "define('FS_METHOD', 'direct');" >> /var/www/html/wp-config.php

 #Configure apache2 for suitecrm
echo "<VirtualHost *:80>
     ServerAdmin admin@mysuitecrm.com
     DocumentRoot /var/www/html/suitecrm/
     ServerName mysuitecrm.com
     ServerAlias www.mysuitecrm.com

     <Directory /var/www/html/suitecrm/>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Order allow,deny
        allow from all
     </Directory>

     ErrorLog ${APACHE_LOG_DIR}/error.log
     CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" > /etc/apache2/sites-available/suitecrm.conf

echo $PW | sudo service apache2 reload
echo $PW | sudo a2ensite suitecrm.conf
echo $PW | sudo a2enmod rewrite
echo $PW | sudo systemctl restart apache2
