#!/bin/bash
MARIADB_ROOT_PASS=ragnarok
RAGNAROK_DATABASE_PASS=ragnarok
RO_PACKET_VER=20121004

export NEEDRESTART_MODE=a
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical

sudo debconf-set-selections <<< "mariadb-server mysql-server/root_password password $MARIADB_ROOT_PASS"
sudo debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password $MARIADB_ROOT_PASS" 

sudo apt-get -y update && sudo apt-get upgrade --yes && sudo apt-get -y install net-tools build-essential nginx \
  php8.1-fpm zlib1g-dev libpcre3-dev libmariadb-dev libmariadb-dev-compat mariadb-server mariadb-client npm
WAN_IP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
echo ${WAN_IP}

##
# configure nginx for php
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
chmod 777 -R /etc/nginx/sites-available/
systemctl restart nginx # restart to finalize changes
systemctl restart php8.1-fpm
#
##


##
#clone repo for robrowser - a javascript based web client for ragnarok online
cd /var/www/html/ && git clone https://github.com/MrAntares/roBrowserLegacy.git
##

#hack to fix equip on 20121004
#
sed -i 's/if(PACKETVER.value >= 20120925) {/if(PACKETVER.value >= 20130320) {/g' /var/www/html/roBrowserLegacy/src/Network/PacketStructure.js
#
##

##
# write the frontend's index.html
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
#
##

##
# install wsproxy
mkdir /home/ragnarok/
cd /home/ragnarok/
npm install wsproxy -g
#
##

##
# get rathena from github and compile it
mkdir /home/rathena && cd /home/rathena && git clone https://github.com/rathena/rathena.git
# testing a hack somebody provided for rathena's packets
sed -i '48 s/^/\/\/ /' /home/rathena/rathena/src/config/packets.hpp
sed -i '56 s/^/\/\/ /' /home/rathena/rathena/src/config/packets.hpp
# set packetver and compile rathena
cd /home/rathena/rathena
bash /home/rathena/rathena/configure --enable-epoll=yes --enable-prere=no --enable-vip=no --enable-packetver=${RO_PACKET_VER}
make clean && make server
#
##


##
# install ragnarok database
echo "FLUSH PRIVILEGES;
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
" > create_user.sql
mysql < create_user.sql
#
##

##
#set ragnarok database pass in rathena config
sed -i 's/login_server_pw: ragnarok/login_server_pw: '"$RAGNAROK_DATABASE_PASS"'/g' /home/rathena/rathena/conf/login_athena.conf
sed -i 's/ipban_db_pw: ragnarok/ipban_db_pw: '"$RAGNAROK_DATABASE_PASS"'/g' /home/rathena/rathena/conf/login_athena.conf
sed -i 's/char_server_pw: ragnarok/char_server_pw: '"$RAGNAROK_DATABASE_PASS"'/g' /home/rathena/rathena/conf/login_athena.conf
sed -i 's/map_server_pw: ragnarok/map_server_pw: '"$RAGNAROK_DATABASE_PASS"'/g' /home/rathena/rathena/conf/login_athena.conf
sed -i 's/web_server_pw: ragnarok/web_server_pw: '"$RAGNAROK_DATABASE_PASS"'/g' /home/rathena/rathena/conf/login_athena.conf
sed -i 's/log_db_pw: ragnarok/log_db_pw: '"$RAGNAROK_DATABASE_PASS"'/g' /home/rathena/rathena/conf/login_athena.conf
#
##

##
#rathena QOL changes
sed -i 's/new_account: no/new_account: yes/g' /home/rathena/rathena/conf/login_athena.conf
sed -i 's/start_point: iz_int,18,26:iz_int01,18,26:iz_int02,18,26:iz_int03,18,26:iz_int04,18,26/start_point: prontera,155,187/g' /home/rathena/rathena/conf/char_athena.conf
sed -i 's/start_point_pre: new_1-1,53,111:new_2-1,53,111:new_3-1,53,111:new_4-1,53,111:new_5-1,53,111/start_point: prontera,155,187/g' /home/rathena/rathena/conf/char_athena.conf
sed -i 's/start_point_doram: lasa_fild01,48,297/start_point: prontera,155,187/g' /home/rathena/rathena/conf/char_athena.conf
sed -i 's/server_name: rAthena/server_name: ragnarok.sh/g' /home/rathena/rathena/conf/char_athena.conf
#
##

##
# enable rathena base custom npcs
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
#
##

##
# start server first time. Note, for further restarts just restart the whole ass server. See that crontab up there? yep.
cd /home/rathena/rathena/
nohup bash athena-start start &
wsproxy -p 5999 -a localhost:6900,localhost:6121,localhost:5121
##
