sudo apt-get install default-jdk

sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

wget http://apache.mirrors.ionfish.org/tomcat/tomcat-8/v8.0.50/bin/apache-tomcat-8.0.50.tar.gz
sudo tar -xzvf apache-tomcat-8.0.50.tar.gz
sudo mv apache-tomcat-8.0.50 /opt/tomcat

sudo chgrp -R tomcat /opt/tomcat
sudo chown -R tomcat /opt/tomcat
sudo chmod -R 755 /opt/tomcat

#sudo nano /etc/systemd/system/tomcat.service
cat << EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Server
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=15
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl status tomcat

sudo systemctl enable tomcat
sudo ufw allow 8080


#sudo nano /opt/tomcat/conf/tomcat-users.xml
sed '/<role rolename="admin-gui"/>/i\ <user username="username" password="password" roles="manager-gui,admin-gui"/>' /opt/tomcat/conf/tomcat-users.xml
sed '/<user username="username" password="password" roles="manager-gui,admin-gui"/>/i\ </tomcatusers>' /opt/tomcat/conf/tomcat-users.xml
sed '/<role rolename="manager-gui"/>/i\ <role rolename="admin-gui"/>' /opt/tomcat/conf/tomcat-users.xml

#sudo nano /opt/tomcat/webapps/manager/META-INF/context.xml
sed -i 's/  <!--
  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />
  -->/  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="150\.252\.118\.202|127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />/g' /opt/tomcat/webapps/manager/META-INF/context.xml

#sudo nano /opt/tomcat/webapps/host-manager/META-INF/context.xml
sed -i 's/  <!--
  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />
  -->/  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="150\.252\.118\.202|127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />/g' /opt/tomcat/webapps/host-manager/META-INF/context.xml

sudo systemctl restart tomcat

rm apache-tomcat-8.0.50.tar.gz




#JOOMLA
wget https://downloads.joomla.org/cms/joomla3/3-7-5/Joomla_3-7.5-Stable-Full_Package.zip
sudo mkdir /var/www/html/joomla
sudo mv Joomla_3-7.5-Stable-Full_Package.zip /var/www/html/joomla
sudo apt-get install unzip
cd /var/www/html/joomla
sudo unzip Joomla_3-7.5-Stable-Full_Package.zip

sudo mv htaccess.txt .htaccess

mysql -u root -p -e "CREATE DATABASE joomla;"
mysql -u root -p -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON moodle.* TO root@localhost IDENTIFIED BY 'nosrebob';"
mysql -u root -p -e "FLUSH PRIVILEGES;"

sudo systemctl restart apache2

cat << EOF > configuration.php
<?php
class JConfig {
	public \$offline = '0';
	public \$offline_message = 'This site is down for maintenance.<br />Please check back again soon.';
	public \$display_offline_message = '1';
	public \$offline_image = '';
	public \$sitename = 'John Wolfe\'s Joomla site';
	public \$editor = 'tinymce';
	public \$captcha = '0';
	public \$list_limit = '20';
	public \$access = '1';
	public \$debug = '0';
	public \$debug_lang = '0';
	public \$dbtype = 'mysqli';
	public \$host = 'localhost';
	public \$user = 'root';
	public \$password = 'nosrebob';
	public \$db = 'joomla';
	public \$dbprefix = 'joomla_';
	public \$live_site = '';
	public \$secret = 'XoXbzUeaP2ESX3TF';
	public \$gzip = '0';
	public \$error_reporting = 'default';
	public \$helpurl = 'https://help.joomla.org/proxy/index.php?keyref=Help{major}{minor}:{keyref}';
	public \$ftp_host = '127.0.0.1';
	public \$ftp_port = '21';
	public \$ftp_user = '';
	public \$ftp_pass = '';
	public \$ftp_root = '';
	public \$ftp_enable = '0';
	public \$offset = 'UTC';
	public \$mailonline = '1';
	public \$mailer = 'mail';
	public \$mailfrom = 'jbw14a@acu.edu';
	public \$fromname = 'John Wolfe\'s Joomla site';
	public \$sendmail = '/usr/sbin/sendmail';
	public \$smtpauth = '0';
	public \$smtpuser = '';
	public \$smtppass = '';
	public \$smtphost = 'localhost';
	public \$smtpsecure = 'none';
	public \$smtpport = '25';
	public \$caching = '0';
	public \$cache_handler = 'file';
	public \$cachetime = '15';
	public \$cache_platformprefix = '0';
	public \$MetaDesc = 'Just another joomla site';
	public \$MetaKeys = '';
	public \$MetaTitle = '1';
	public \$MetaAuthor = '1';
	public \$MetaVersion = '0';
	public \$robots = '';
	public \$sef = '1';
	public \$sef_rewrite = '0';
	public \$sef_suffix = '0';
	public \$unicodeslugs = '0';
	public \$feed_limit = '10';
	public \$feed_email = 'none';
	public \$log_path = '/var/www/html/joomla/administrator/logs';
	public \$tmp_path = '/var/www/html/joomla/tmp';
	public \$lifetime = '15';
	public \$session_handler = 'database';
	public \$shared_session = '0';
}
EOF

sudo rm Joomla_3-7.5-Stable-Full_Package.zip
sudo rm -r installation

cd ~
