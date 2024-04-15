#!/bin/bash
MARIADB_ROOT_PASS=ragnarok
RAGNAROK_DATABASE_PASS=ragnarok
RO_PACKET_VER=20121004

#RAGNAROK_USER_PASS=ragnarok
#RATHENA_USER_PASS=ragnarok
sudo apt-get -y update && sudo NEEDRESTART_SUSPEND=1 apt-get upgrade --yes
sudo NEEDRESTART_SUSPEND=1 apt-get -y install net-tools
WAN_IP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
echo ${WAN_IP}


#create ragnarok account
#adduser --quiet --disabled-password --shell /bin/bash --home /home/ragnarok --gecos "User" ragnarok
#echo "ragnarok:${RAGNAROK_USER_PASS}" | chpasswd
#usermod -aG sudo ragnarok
##

#install nginx as ragnarok
#su ragnarok
#sudo apt-get -y update && sudo NEEDRESTART_SUSPEND=1 apt-get upgrade --yes
sudo NEEDRESTART_SUSPEND=1 apt-get -y install nginx
sudo NEEDRESTART_SUSPEND=1 apt-get install php8.1-fpm -y
cd /etc/nginx/sites-available/
mv default default.old
echo "server {
        listen 80 default_server;
        listen [::]:80 default_server;


    root /var/www/html;
    index index.php index.html index.htm;


        server_name _;


         location / {
                      try_files \$uri \$uri/ /index.php\$is_args\$args;
         }

         location ~ \.php\$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)\$;
            fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
            fastcgi_index index.php;
            include fastcgi.conf;
    }

}
" > default
echo " <html xmlns=\"http://www.w3.org/1999/xhtml\">    
  <head>      
    <title>ragnarok.sh</title>      
    <meta http-equiv=\"refresh\" content=\"0;URL='http://${WAN_IP}/roBrowserLegacy/examples/api-online-popup.html'\" />    
  </head>    
  <body> 
    <p>Redirecting to the <a href=\"http://${WAN_IP}/roBrowserLegacy/examples/api-online-popup.html\">
      example url</a>.</p> 
  </body>    
</html>" > /var/www/html/index.html
chmod 777 -R /etc/nginx/sites-available/
chmod 775 /var/www/html/index.html
systemctl restart nginx
systemctl restart php8.1-fpm

cd /var/www/html/
##
#clone repo for robrowser
cd /var/www/html/ && git clone https://github.com/MrAntares/roBrowserLegacy.git

cd /var/www/html/roBrowserLegacy/examples/

##
#hack to fix equip on 20121004
sed -i 's/if(PACKETVER.value >= 20120925) {/if(PACKETVER.value >= 20130320) {/g' /var/www/html/roBrowserLegacy/src/Network/PacketStructure.js
##

echo "
<!DOCTYPE html>
<html>
        <head>
                <title>Ragnarok</title>
                <meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=yes\" />
                <script type=\"text/javascript\" src=\"roBrowserLegacy/api.js\"></script>
                <script type=\"text/javascript\">
                        function initialize() {
                                var ROConfig = {
                                        target:        document.getElementById(\"robrowser\"),
                                        type:          ROBrowser.TYPE.FRAME,
                                        application:   ROBrowser.APP.ONLINE,
                                        development:    true,
                                        servers: [{
                                                display:     \"Demo Server\",
                                                desc:        \"roBrowser's demo server\",
                                                address:     \"${WAN_IP}\",
                                                port:        6900,
                                                version:     25,
                                                langtype:    12,
                                                packetver:   ${RO_PACKET_VER},
                                                packetKeys:  false,
                                                socketProxy: \"ws://${WAN_IP}:5999/\",
                                                adminList:   []
                                        }],
                                        skipServerList:  true,
                                        skipIntro:       true,
                                };
                                var RO = new ROBrowser(ROConfig);
                                RO.start();
                        }
                        window.addEventListener(\"load\", initialize, false);
                </script>
        </head>
        <body bgcolor=\"black\" style=\"overflow: hidden;\">
        <div id=\"robrowser\" style=\"height:100vh; width:100vw; position: fixed; left: 0; top:0; overflow: hidden;\"></div>
        </body>
</html>
" > /var/www/html/index.html
mkdir /home/ragnarok/
cd /home/ragnarok/
sudo NEEDRESTART_SUSPEND=1 apt-get -y install npm
npm install wsproxy -g

#create user for rathena
#adduser --quiet --disabled-password --shell /bin/bash --home /home/rathena --gecos "User" rathena
#echo "rathena:${RAGNAROK_USER_PASS}" | chpasswd
#usermod -aG sudo rathena
#su rathena

mkdir /home/rathena
cd /home/rathena
sudo apt-get -y update && sudo NEEDRESTART_SUSPEND=1 apt-get upgrade --yes

#install some pre-requisites

sudo NEEDRESTART_SUSPEND=1 apt -y install build-essential zlib1g-dev libpcre3-dev
sudo NEEDRESTART_SUSPEND=1 apt -y install libmariadb-dev libmariadb-dev-compat
cd /home/rathena & git clone https://github.com/rathena/rathena.git
cd /home/rathena/rathena

##
# testing a hack somebody provided
sed -i '48 s/^/\/\/ /' /home/rathena/rathena/src/config/packets.hpp
sed -i '56 s/^/\/\/ /' /home/rathena/rathena/src/config/packets.hpp
##

## old packetver
#bash /home/rathena/rathena/configure --enable-epoll=yes --enable-prere=no --enable-vip=no --enable-packetver=20131223
##
bash /home/rathena/rathena/configure --enable-epoll=yes --enable-prere=no --enable-vip=no --enable-packetver=${RO_PACKET_VER}

make clean && make server


export DEBIAN_FRONTEND="noninteractive"
sudo debconf-set-selections <<< "mariadb-server mysql-server/root_password password $MARIADB_ROOT_PASS"
sudo debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password $MARIADB_ROOT_PASS" 

sudo NEEDRESTART_SUSPEND=1 apt-get install -y mariadb-server
sudo NEEDRESTART_SUSPEND=1 apt-get -y install mariadb-client

cd /home/rathena/rathena

MARIADB_STRING="FLUSH PRIVILEGES;
drop user if exists 'ragnarok'@'localhost';
drop user if exists ragnarok; DROP DATABASE IF EXISTS ragnarok;
create user 'ragnarok'@'localhost' identified by '${RAGNAROK_DATABASE_PASS}';
FLUSH PRIVILEGES;
CREATE DATABASE ragnarok; GRANT ALL ON ragnarok.* TO 'ragnarok'@'localhost';
FLUSH PRIVILEGES;
use ragnarok;
show tables;
source /home/rathena/rathena/sql-files/item_db.sql;
source /home/rathena/rathena/sql-files/item_db_equip.sql;
source /home/rathena/rathena/sql-files/item_db_equip.sql;
source /home/rathena/rathena/sql-files/item_db_etc.sql;
source /home/rathena/rathena/sql-files/item_db_re.sql;
source /home/rathena/rathena/sql-files/item_db_re_equip.sql;
source /home/rathena/rathena/sql-files/item_db_re_etc.sql;
source /home/rathena/rathena/sql-files/item_db2.sql;
source /home/rathena/rathena/sql-files/item_db_re_usable.sql;
source /home/rathena/rathena/sql-files/item_db_usable.sql;
source /home/rathena/rathena/sql-files/item_db2_re.sql;
source /home/rathena/rathena/sql-files/main.sql;
source /home/rathena/rathena/sql-files/mob_db.sql;
source /home/rathena/rathena/sql-files/mob_skill_db.sql;
source /home/rathena/rathena/sql-files/mob_db_re.sql;
source /home/rathena/rathena/sql-files/mob_db2.sql;
source /home/rathena/rathena/sql-files/mob_db2_re.sql;
source /home/rathena/rathena/sql-files/mob_skill_db2_re.sql;
source /home/rathena/rathena/sql-files/mob_skill_db_re.sql;
source /home/rathena/rathena/sql-files/mob_skill_db2.sql;
source /home/rathena/rathena/sql-files/web.sql;
source /home/rathena/rathena/sql-files/roulette_default_data.sql;
source /home/rathena/rathena/sql-files/logs.sql;
"
echo $MARIADB_STRING > create_user.sql
mysql < create_user.sql

echo "${SECURE_MYSQL_3}"
#set ragnarok database pass
sed -i 's/login_server_pw: ragnarok/login_server_pw: '"$RAGNAROK_DATABASE_PASS"'/g' /home/rathena/rathena/conf/login_athena.conf
sed -i 's/ipban_db_pw: ragnarok/ipban_db_pw: '"$RAGNAROK_DATABASE_PASS"'/g' /home/rathena/rathena/conf/login_athena.conf
sed -i 's/char_server_pw: ragnarok/char_server_pw: '"$RAGNAROK_DATABASE_PASS"'/g' /home/rathena/rathena/conf/login_athena.conf
sed -i 's/map_server_pw: ragnarok/map_server_pw: '"$RAGNAROK_DATABASE_PASS"'/g' /home/rathena/rathena/conf/login_athena.conf
sed -i 's/web_server_pw: ragnarok/web_server_pw: '"$RAGNAROK_DATABASE_PASS"'/g' /home/rathena/rathena/conf/login_athena.conf
sed -i 's/log_db_pw: ragnarok/log_db_pw: '"$RAGNAROK_DATABASE_PASS"'/g' /home/rathena/rathena/conf/login_athena.conf

##
#QOL changes
sed -i 's/new_account: no/new_account: yes/g' /home/rathena/rathena/conf/login_athena.conf
sed -i 's/start_point: iz_int,18,26:iz_int01,18,26:iz_int02,18,26:iz_int03,18,26:iz_int04,18,26/start_point: prontera,155,187/g' /home/rathena/rathena/conf/char_athena.conf
sed -i 's/start_point_pre: new_1-1,53,111:new_2-1,53,111:new_3-1,53,111:new_4-1,53,111:new_5-1,53,111/start_point: prontera,155,187/g' /home/rathena/rathena/conf/char_athena.conf
sed -i 's/start_point_doram: lasa_fild01,48,297/start_point: prontera,155,187/g' /home/rathena/rathena/conf/char_athena.conf
sed -i 's/server_name: rAthena/server_name: ragnarok.sh/g' /home/rathena/rathena/conf/char_athena.conf
#
##

##
# enable base custom npcs
sed -i 's/\/\/npc: npc\/custom\/warper.txt/npc: npc\/custom\/warper.txt/g' /home/rathena/rathena/npc/scripts_custom.conf
sed -i 's/\/\/npc: npc\/custom\/jobmaster.txt/npc: npc\/custom\/jobmaster.txt/g' /home/rathena/rathena/npc/scripts_custom.conf
sed -i 's/\/\/npc: npc\/custom\/platinum_skills.txt/npc: npc\/custom\/platinum_skills.txt/g' /home/rathena/rathena/npc/scripts_custom.conf
sed -i 's/\/\/npc: npc\/custom\/healer.txt/npc: npc\/custom\/healer.txt/g' /home/rathena/rathena/npc/scripts_custom.conf
sed -i 's/\/\/npc: npc\/custom\/breeder.txt/npc: npc\/custom\/breeder.txt/g' /home/rathena/rathena/npc/scripts_custom.conf
sed -i 's/\/\/npc: npc\/custom\/card_seller.txt/npc: npc\/custom\/card_seller.txt/g' /home/rathena/rathena/npc/scripts_custom.conf
sed -i 's/\/\/npc: npc\/custom\/itemmall.txt/npc: npc\/custom\/itemmall.txt/g' /home/rathena/rathena/npc/scripts_custom.conf
sed -i 's/\/\/npc: npc\/custom\/stylist.txt/npc: npc\/custom\/stylist.txt/g' /home/rathena/rathena/npc/scripts_custom.conf
sed -i 's/\/\/npc: npc\/custom\/resetnpc.txt/npc: npc\/custom\/resetnpc.txt/g' /home/rathena/rathena/npc/scripts_custom.conf
sed -i 's/\/\/npc: npc\/custom\/card_remover.txt/npc: npc\/custom\/card_remover.txt/g' /home/rathena/rathena/npc/scripts_custom.conf
sed -i 's/\/\/npc: npc\/custom\/item_signer.txt/npc: npc\/custom\/item_signer.txt/g' /home/rathena/rathena/npc/scripts_custom.conf
sed -i 's/\/\/npc: npc\/custom\/woe_controller.txt/npc: npc\/custom\/woe_controller.txt/g' /home/rathena/rathena/npc/scripts_custom.conf
#
##

##
#add to crontab so it starts the server on reboot
(crontab -l 2>/dev/null; echo "@reboot sleep 5 && cd /home/rathena/rathena/ && nohup bash athena-start start \&") | crontab -
(crontab -l 2>/dev/null; echo "@reboot sleep 6 && wsproxy -p 5999 -a localhost:6900,localhost:6121,localhost:5121") | crontab -
#start server
cd /home/rathena/rathena/
nohup bash athena-start start &
wsproxy -p 5999 -a localhost:6900,localhost:6121,localhost:5121