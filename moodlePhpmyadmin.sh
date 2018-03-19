
sudo apt-get -y update
sudo apt-get -y upgrade

#Install additional software for phpmyadmin. Installing phpmyadmin also installs apache2
sudo apt-get -y install phpmyadmin php-mbstring php-gettext
#Debconf screen appears for installing phpmyadmin. Test below commands to automate phpmyadmin debconf screen
# echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections
# echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | debconf-set-selections
# echo 'phpmyadmin phpmyadmin/app-password-confirm password your-app-pwd' | debconf-set-selections
# echo 'phpmyadmin phpmyadmin/mysql/admin-pass password your-admin-db-pwd' | debconf-set-selections
# echo 'phpmyadmin phpmyadmin/mysql/app-pass password your-app-db-pwd' | debconf-set-selections


#Install rest of LAMP stack
sudo apt-get -y install mysql-client mysql-server
sudo apt-get -y install php libapache2-mod-php

#Enable PHP mcrypt and mbstring extensions
sudo phpenmod mcrypt
sudo phpenmod mbstring

#Install additional software for Moodle
sudo apt-get -y install graphviz aspell
sudo apt-get -y install php-pspell php-curl php-gd php-intl php-mysql php-xml php-xmlrpc php-ldap php-zip

#Restart apache
sudo systemctl restart apache2

#Install Git for later usage
sudo apt-get -y install git-core

#Open port 443, 80, 3306, etc
cat <<EOF >> /etc/iptables.firewall.rules
* filter

#  Allow all loopback (lo0) traffic and drop all traffic to 127/8 that doesn't use lo0
-A INPUT -i lo -j ACCEPT
-A INPUT -d 127.0.0.0/8 -j REJECT

#  Accept all established inbound connections
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#  Allow all outbound traffic - you can modify this to only allow certain traffic
-A OUTPUT -j ACCEPT

#  Allow HTTPS and HTTP and MySQL connections
-A INPUT -p tcp --dport 80 -j ACCEPT
-A INPUT -p tcp --dport 443 -j ACCEPT
-A INPUT -p tcp --dport 3306 -j ACCEPT

# Allow dns and ldap
-A INPUT -p tcp --dport 53 -j ACCEPT
-A INPUT -p tcp --dport 389 -j ACCEPT

#  Allow SSH connections

#  The -dport number should be the same port number you set in sshd_config
-A INPUT -p tcp -m state --state NEW --dport 22 -j ACCEPT

#  Log iptables denied calls
-A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7

#  Drop all other inbound - default deny unless explicitly allowed policy
-A INPUT -j DROP
-A FORWARD -j DROP

COMMIT
EOF



#Download moodle into /opt directory, retrieve a list of branches from moodle repo, track the MOODLE_31_STABLE
#branch and then checkout the MOODLE_31_STABLE branch
cd /opt
sudo git clone git://git.moodle.org/moodle.git
cd moodle
sudo git branch -a
sudo git branch --track MOODLE_31_STABLE orgin/MOODLE_31_STABLE
sudo git checkout MOODLE_31_STABLE

cd ~

#Copy the Moodle repository to my /var/www/html, create new directory to hold moodle data and then set
#folder privileges
sudo cp -R /opt/moodle /var/www/html/
sudo mkdir /var/moodledata
sudo chown -R www-data /var/moodledata
sudo chmod -R 777 /var/moodledata
sudo chmod -R 0755 /var/www/html/moodle

#Change the default storage engine to innodb and change the default file format to Barracuda
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
#Edit the following lines to look like:
default_storage_engine = innodb
innodb_file_per_table = 1
innodb_file_format = Barracuda
#Exit nano editor

#Restart mysql
sudo service mysql restart

#Create Moodle database and user
mysql -u root -p

#Use these mysql commands
CREATE DATABASE moodle DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE USER 'jbw14a'@'localhost' IDENTIFIED BY 'Galax3**';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON moodle.* TO jbw14a@localhost IDENTIFIED BY 'Galax3**';
quit;

#Setup a cron job
#Open crontab editor:
crontab -u www-data -e
#Add the following line
*/15 * * * * /usr/bin/php  /path/to/moodle/admin/cli/cron.php >/dev/null
#This sends all the output to the 'bin' and stops you getting an email every 15 minutes.

#The below command supposedly automate the above cron job for Debian and Redhat systems. Try it ou soon
#*/15  *     * * *     www-data   cd  /path/to/moodle/admin/cli/; /usr/bin/php cron.php  >/dev/null



#Momentarily change permissions of the moodle webroot to let it be writable
sudo chmod -R 777 /var/www/html/moodle

#NOW, got to browser and finish installation
#TODO: A config.php file is generated when finishing the installation via the browser
#      For the Unattended install, keep the above config.php file as a template
#      to make the full installation of moodle unattended with no browser interaction

#After finish the final setup steps in the browser, revert permissions back to the way they used to be
sudo chmod -R 0755 /var/www/html/moodle
