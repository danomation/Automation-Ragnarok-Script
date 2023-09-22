#!/bin/bash
MARIADB_ROOT_PASS=Password123!
RAGNAROK_DATABASE_PASS=ragnarok

RAGNAROK_USER_PASS=Password123!
RATHENA_USER_PASS=Password123!

WAN_IP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
echo WAN_IP


#create ragnarok account
adduser --quiet --disabled-password --shell /bin/bash --home /home/ragnarok --gecos "User" ragnarok
echo "ragnarok:${RAGNAROK_USER_PASS}" | chpasswd
usermod -aG sudo ragnarok
##

#install nginx as ragnarok
#su ragnarok
sudo apt-get -y update && sudo NEEDRESTART_SUSPEND=1 apt-get upgrade --yes
sudo NEEDRESTART_SUSPEND=1 apt-get -y install nginx
sudo NEEDRESTART_SUSPEND=1 apt-get install php8.1-fpm -y
cd /etc/nginx/sites-available/
echo "server {
        listen 80 default_server;
        listen [::]:80 default_server;


    root /var/www/html;
    index index.php index.html index.htm;


        server_name _;


    location / {
        try_files $uri $uri/ =404;
    }


    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    }
}" > default
cat 777 /etc/nginx/sites-available/default
systemctl restart nginx

cd /var/www/html/
##
#clone repo for robrowser
sudo git clone https://github.com/MrAntares/roBrowserLegacy.git .

cd /var/www/html/roBrowserLegacy/examples/
echo "<!DOCTYPE html><html><head><title>ROBrowser's App from http://www.robrowser.com</title>
<meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=yes\" />
<script type=\"text/javascript\" src=\"../api.js\"></script>
<script type=\"text/javascript\">
function initialize() {
    var ROConfig = {
    target:        document.getElementById(\"robrowser\"),
    type:          ROBrowser.TYPE.FRAME,
    application:   ROBrowser.APP.ONLINE,
    remoteClient:  \"http://grf.robrowser.com/\",
    width:          800,
    height:         600,
    development:    false,
    servers: [{
        display:     \"Local Test\",
        desc:        \"Local Demo Server\",
        address:     \"localhost\",
        port:        6900,
        version:     25,
        langtype:    12,
        packetver:   20131223,
        packetKeys:  true,
        socketProxy: \"ws://${WAN_IP}:5999/\",
        adminList:   [2000000]
    }],
    skipServerList:  true,
    skipIntro:       false,
    };
var RO = new ROBrowser(ROConfig);
RO.start();
}
window.addEventListener(\"load\", initialize, false);
</script></head><body><div id=\"robrowser\">Initializing roBrowser...</div></body></html>
" > api-online-frame.html

cd /home/ragnarok/
sudo NEEDRESTART_SUSPEND=1 apt-get -y install npm
npm install wsproxy -g

#create user for rathena
adduser --quiet --disabled-password --shell /bin/bash --home /home/rathena --gecos "User" rathena
echo "rathena:${RAGNAROK_USER_PASS}" | chpasswd
usermod -aG sudo rathena

#su rathena
cd /home/rathena
sudo apt-get -y update && sudo NEEDRESTART_SUSPEND=1 apt-get upgrade --yes

#install some pre-requisites

sudo NEEDRESTART_SUSPEND=1 apt -y install build-essential zlib1g-dev libpcre3-dev
sudo NEEDRESTART_SUSPEND=1 apt -y install libmariadb-dev libmariadb-dev-compat
cd /home/rathena
git clone https://github.com/rathena/rathena.git .
cd /home/rathena/rathena
/home/rathena/rathena/configure --enable-epoll=yes --enable-prere=no --enable-vip=no --enable-packetver=20131223
make clean && make server
sudo NEEDRESTART_SUSPEND=1 apt -y install mariadb-server
sudo NEEDRESTART_SUSPEND=1 apt-get -y install mariadb-client
sudo NEEDRESTART_SUSPEND=1 apt-get -y install expect

cd /home/rathena
MARIADB_STRING="FLUSH PRIVILEGES;
drop user if exists 'ragnarok'@'localhost';
drop user if exists ragnarok; DROP DATABASE IF EXISTS ragnarok;
create user 'ragnarok'@'localhost' identified by '${RAGNAROK_DATABASE_PASS}';
FLUSH PRIVILEGES;
CREATE DATABASE ragnarok; GRANT ALL ON ragnarok.* TO 'ragnarok'@'localhost';
FLUSH PRIVILEGES;"


        SECURE_MYSQL=$(expect -c "
        set timeout 3
        spawn mysql_secure_installation
        expect \"Enter current password for root (enter for none):\"
        send \"\r\"
        expect \"Switch to unix_socket authentication \[Y/n\]\"
        send \"n\r\"
        expect \"Set root password? \[Y/n\]\"
        send \"y\r\"
        expect \"New password:\"
        send \"${MARIADB_ROOT_PASS}\r\"
        expect \"Re-enter new password:\"
        send \"${MARIADB_ROOT_PASS}\r\"
        expect \"Remove anonymous users? \[Y/n\]\"
        send \"y\r\"
        expect \"Disallow root login remotely? \[Y/n\]\"
        send \"n\r\"
        expect \"Remove test database and access to it? \[Y/n\]\"
        send \"y\r\"
        expect \"Reload privilege tables now? \[Y/n\]\"
        send \"y\r\"
        expect eof
        ")

echo "${SECURE_MYSQL}"


        SECURE_MYSQL_2=$(expect -c "
        set timeout 3
        spawn mysql -u root -p -e \"${MARIADB_STRING}\"
        expect \"Enter password:\"
        send \"${MARIADB_ROOT_PASS}\r\"
        expect eof
        send \"exit\r\"
        expect eof
        ")

echo "${SECURE_MYSQL_2}"

        SECURE_MYSQL_3=$(expect -c "
        set timeout 3
        spawn mysql -u root -p
        expect \"Enter password:\"
        send \"${MARIADB_ROOT_PASS}\r\"
        expect eof
        send \"use ragnarok;\r\"
        expect eof
        send \"show tables;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/item_db.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/item_db_equip.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/item_db_etc.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/item_db_re.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/item_db_re_equip.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/item_db_re_etc.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/item_db2.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/item_db_re_usable.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/item_db_usable.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/item_db2_re.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/main.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/mob_db.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/mob_skill_db.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/mob_db_re.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/mob_db2.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/mob_db2_re.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/mob_skill_db2_re.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/mob_skill_db_re.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/mob_skill_db2.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/web.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/roulette_default_data.sql;\r\"
        expect eof
        send \"source /home/rathena/rathena/sql-files/logs.sql;\r\"
        expect eof
        send \"exit\r\"
        expect eof
        ")

echo "${SECURE_MYSQL_3}"

bash /home/rathena/rathena/athena-start start
cd /home/ragnarok/
sudo wsproxy -p 5999 -a localhost:6900,localhost:6121,localhost:5121
