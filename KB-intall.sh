#!bin/bash

### VARIABLES ###

primaryIP=allipaddr=`ip -4 -o addr| awk '{gsub(/\/.*/,"",$4); print $4}'`


##### Mariadb 10.1 and phpmyfaq DB creation.

cd /etc/yum.repos.d
#wget http://172.16.20.10/cfgs/repos/centos7/mariadb101-amd64.repo
wget http://$primaryIP/cfgs/repos/centos7/mariadb101-amd64.repo
cd /
yum clean all && yum -y update
yum -y install MariaDB MariaDB-server MariaDB-client galera
yum -y install crudini

echo "" > /etc/my.cnf.d/server-tac.cnf

crudini --set /etc/my.cnf.d/server-tac.cnf mysqld binlog_format ROW
crudini --set /etc/my.cnf.d/server-tac.cnf mysqld default-storage-engine innodb
crudini --set /etc/my.cnf.d/server-tac.cnf mysqld innodb_autoinc_lock_mode 2
crudini --set /etc/my.cnf.d/server-tac.cnf mysqld query_cache_type 0
crudini --set /etc/my.cnf.d/server-tac.cnf mysqld query_cache_size 0
crudini --set /etc/my.cnf.d/server-tac.cnf mysqld bind-address 0.0.0.0
crudini --set /etc/my.cnf.d/server-tac.cnf mysqld max_allowed_packet 1024M
crudini --set /etc/my.cnf.d/server-tac.cnf mysqld max_connections 1000
crudini --set /etc/my.cnf.d/server-tac.cnf mysqld innodb_doublewrite 1
crudini --set /etc/my.cnf.d/server-tac.cnf mysqld innodb_log_file_size 100M
crudini --set /etc/my.cnf.d/server-tac.cnf mysqld innodb_flush_log_at_trx_commit 2
echo "innodb_file_per_table" >> /etc/my.cnf.d/server-tac.cnf

systemctl enable mariadb.service
systemctl start mariadb.service

/usr/bin/mysqladmin -u root password "T@C3Mpr3S@r1@LMDB"

echo "[client]" > /root/.my.cnf
echo "user = "root"" >> /root/.my.cnf
echo "password = \"T@C3Mpr3S@r1@LMDB\""  >> /root/.my.cnf 
echo "host = \"localhost\""  >> /root/.my.cnf

mysql -e "CREATE DATABASE phpmyfaqdb default character set utf8;"
mysql -e "GRANT ALL ON phpmyfaqdb.* TO 'phpmyfaqdbuser'@'%' IDENTIFIED BY 'P7Pm6F@Q7S3rDB';"
mysql -e "GRANT ALL ON phpmyfaqdb.* TO 'phpmyfaqdbuser'@'127.0.0.1' IDENTIFIED BY 'P7Pm6F@Q7S3rDB';"
mysql -e "GRANT ALL ON phpmyfaqdb.* TO 'phpmyfaqdbuser'@'localhost' IDENTIFIED BY 'P7Pm6F@Q7S3rDB';"
mysql -e "FLUSH PRIVILEGES;"

### DEPENDENCIES INSTALLATION, (Apache, etc.):

yum -y install php-cli php php-gd php-mysql httpd gd \
perl-Archive-Tar perl-MIME-Lite perl-MIME-tools \
perl-Date-Manip perl-PHP-Serialization \
perl-Archive-Zip perl-Module-Load \
php php-mysql php-pear php-pear-DB php-mbstring \
php-process perl-Time-HiRes perl-Net-SFTP-Foreign \
perl-Expect libjpeg-turbo perl-Convert-BinHex \
perl-Date-Manip perl-DBD-MySQL perl-DBI \
perl-Email-Date-Format perl-IO-stringy perl-IO-Zlib \
perl-MailTools perl-MIME-Lite perl-MIME-tools perl-MIME-Types \
perl-Module-Load perl-Package-Constants \
perl-Time-HiRes perl-TimeDate perl-YAML-Syck php

3.- Descarga y descrompresion de phpmyfaq:

mkdir /workdir
cd /workdir
wget http://download.phpmyfaq.de/phpMyFAQ-2.8.29.zip
unzip phpMyFAQ-2.8.29.zip -d /var/www/html/
chown -R root.root /var/www/html/phpmyfaq


4.- Configuración inicial de phpmyfaq y php.ini:

cd /var/www/html/phpmyfaq/
mkdir images
mkdir attachments
mkdir data
chown -R apache.apache images data lang attachments admin/images config

cd /var/www/html/phpmyfaq/config
sed -r -i 's/Europe\/Berlin/America\/Caracas/g' constants.php
mv /var/www/html/phpmyfaq/_.htaccess /var/www/html/phpmyfaq/.htaccess

crudini --set /etc/php.ini PHP upload_max_filesize 60M

crudini --set /etc/php.ini PHP post_max_size 60M

5.- Configuración de apache:

echo "Alias /phpmyfaq /var/www/html/phpmyfaq" > /etc/httpd/conf.d/phpmyfaq.conf
echo "<location /phpmyfaq>" >> /etc/httpd/conf.d/phpmyfaq.conf
echo "  Options +FollowSymlinks -MultiViews -Indexes" >> /etc/httpd/conf.d/phpmyfaq.conf
echo "</location>" >> /etc/httpd/conf.d/phpmyfaq.conf

systemctl restart httpd
systemctl enable httpd

6.- Configuración final de phpmyfaq:

Se ingresa al siguiente URL:

http://172.16.20.11/phpmyfaq/install/setup.php

Se seleccionan/completan los siguientes datos en la página de setup:

Database Server: MySQL/MariaDB 5.x
Database Hostname: 127.0.0.1
Database User: phpmyfaqdbuser
Database Password: P7Pm6F@Q7S3rDB
Database Name: phpmyfaqdb
Table prefix: _ (el simbolo de underscore... "_")
Default language: Spanish
Permission Level: medium (with group support)
Your name: TAC PHP Admin
Your e-mail: Colocar un email válido. Ejemplo: rrmartinezp@tacempresarial.com.ve
Your login name: admin
Your Password: l1n4xvzla
Retype Password: l1n4xvzla

Finalmente se hace click en "install phpmyfaq" (al fondo de la página).

Luego, se completa la encuesta y se hace click para enviarla.

Una vez completado este proceso, en la consola ssh del servidor se ejecutan los siguientes comandos:

chmod 0400 /var/www/html/phpmyfaq/install/setup.php
chmod 0400 /var/www/html/phpmyfaq/install/update.php

Ya en este punto se puede ingresar a los siguientes URL:

URL Principal: http://172.16.20.11/phpmyfaq
URL de Administración: http://172.16.20.11/phpmyfaq/admin/index.php

7.- Opcional: Index redirect:

Si se requiere un redirect desde el root-web del servidor apache, se debe crear el archivo siguiente:

vi /var/www/html/index.html

Con el contenido:

<HTML>
<HEAD>
<META HTTP-EQUIV="refresh" CONTENT="0;URL=/phpmyfaq">
</HEAD>
<BODY>
</BODY>
</HTML>

Se puede crear de manera automatizada de la siguiente forma:

echo "<HTML>" > /var/www/html/index.html
echo "<HEAD>" >> /var/www/html/index.html
echo "<META HTTP-EQUIV=\"refresh\" CONTENT=\"0;URL=/phpmyfaq\">" >> /var/www/html/index.html
echo "</HEAD>" >> /var/www/html/index.html
echo "<BODY>" >> /var/www/html/index.html
echo "</BODY>" >> /var/www/html/index.html
echo "</HTML>" >> /var/www/html/index.html

8.- Respaldos automatizados del phpmyfaq y la base de datos:

En el script de respaldo automatizado del servidor, se incluyó la ruta del php, los archivos de apache del phpmyfaq (control y data), y la base de datos: El script /usr/local/bin/server-backup.sh quedó de la siguiente manera:

#!/bin/bash
#
# Server Backup Script
#
# By Reinaldo Martinez P.
# Caracas, Venezuela.
# TigerLinux AT gmail DOT com
#

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

directory="/mnt/backups/servers-infra"
myhostname=`hostname -s`
timestamp=`date +%Y%m%d%H%M`
daystoremove=5
databasebackupuser="root"
databasebackuppass="T@C3Mpr3S@r1@LMDB"

backuplist='
        /etc/named*
        /var/named/data/*
        /etc/hostname
        /etc/sysconfig/network-scripts/ifcfg-*
        /etc/fstab
        /usr/local/bin/*.sh
        /etc/cron.d/*crontab
        /etc/ntp.conf
        /etc/rc.d/rc.local
        /var/www/html/phpmyfaq
        /etc/php.ini
        /etc/httpd/conf.d/phpmyfaq.conf
'

tar -czvf $directory/backup-server-$myhostname-$timestamp.tgz $backuplist

databases=`echo "show databases"|mysql -s -u $databasebackupuser -p$databasebackuppass`

for i in $databases
do
        nice -n 10 ionice -c2 -n7 \
        mysqldump -u $databasebackupuser \
        -p$databasebackuppass \
        --single-transaction \
        --quick \
        --lock-tables=false \
        $i|gzip > $directory/backup-server-db-$i-$myhostname-$timestamp.gz
done

find $directory/ -name "backup-server-$myhostname-*.tgz" -mtime +$daystoremove -delete
find $directory/ -name "backup-server-db-*$myhostname*gz" -mtime +$daystoremove -delete

#
# END
#

Este script se ejecuta vía crontab (/etc/cron.d/server-backup-crontab) todos los días en la madrugada, y envía toda la data respaldad a /mnt/backups. Este directorio es un punto de montaje contra la NAS, de manera que toda nuestra data queda respaldad de manera externa.

NOTA: El script de respaldo mantiene un histórico de 5 días de todos los respaldos de data y bases de datos del servidor.
