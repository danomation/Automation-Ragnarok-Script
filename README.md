# Automation Script for RO Server + Web Client
This is an automation script for educational purposes. Please respect all copyright laws.  
This bash script automates what can be a complicated install in 12 minutes or so.  
* None of the ragnarok online files are hosted by this github and I cannot provide them.  
* The ragnarok web client was not created by me. It can be found at https://github.com/MrAntares/roBrowserLegacy  
* Their discord is https://discord.gg/8JdHwM4Kqm  

# Instructions - Ubuntu 22.04 (required):
(recommended) Fresh Ubuntu 22.04 VM, open root, and type in command:  
1. ```git clone https://github.com/danomation/ragnarok_script.git && bash ragnarok_script/ragnarok.sh  ```
2. Wait for server to install 15-20mins.
3. Allow incoming ports TCP 80, 5999 if you have a firewall 
4. then navigate to http:// youriphere/ 
---
Or - Using cloud-init script:  
1. Use puttygen to create a private and public key. 
2. Then copy the public OpenSSH key to the below ssh_authorized_keys list.
3. Save your private key, and load it in putty so you can connect.
```
 #cloud-config
 users:
   - name: ragnarok
     groups: users, admin
     sudo: ALL=(ALL) NOPASSWD:ALL
     shell: /bin/bash
     ssh_authorized_keys:
       - <your OpenSSL key(s) here>
 runcmd:
   - git clone 'https://github.com/danomation/Automation-Ragnarok-Script.git' && bash Automation-Ragnarok-Script/ragnarok.sh
   - reboot
```
---
Or - WSL2 (cursed):  
Note: it requires WSL2 (for systemd). see https://askubuntu.com/questions/1379425/system-has-not-been-booted-with-systemd-as-init-system-pid-1-cant-operate 
1. run the following with elevated command prompt
```
wsl --install
wsl --update
wsl --shutdown
wsl --terminate Ubuntu
wsl --unregister Ubuntu
wsl --install -d Ubuntu
(Ubuntu starts) 
(set username and pass) 
sudo passwd
(set password)
su root
(enter password)
git clone 'https://github.com/danomation/Automation-Ragnarok-Script.git' && bash Automation-Ragnarok-Script/ragnarok.sh
(wait until finished)
``` 
2. Open ports 80, 5999 on your router and hyper-v or whatever network switch for WSL  
Note1: If you have a CGNAT (as with fiber companies) buy an ipv4, install it on your router, then forward the ports 80, 5999  
Note2: if you just want to run local and dont want to run with anyone else - then edit /var/www/html/index.html to use localhost for the websocket line ws://. 
3. http://yourwanip or http://localhost

# Known issues:  
1. First sign-on you can't make characters or login.   
Solution: shift+F5 to refresh the client and try again   
2. After changing remote client config the client doesn't load as intended.  
Solution: close all tabs for the server in your browser, delete all cookies and site data, close browser, start browser back up and try.
3. Enabling 443 on webserver causes client not to load due  
Solution: see diagrams below and follow instructions to enable 443  

# Details: 
out of the box diagram: 
![defaultshellscript](https://github.com/danomation/Automation-Ragnarok-Script/assets/17872783/0505ce34-624f-459f-a2d5-615cf48a6425)  
Known issue attempting 443 encryption:
![mixed_http_https_traffic_mismatch](https://github.com/danomation/Automation-Ragnarok-Script/assets/17872783/108ca43f-2560-4702-95df-3ce7c4d04185)  
Potential solution: 
![reverse_proxy_80_to_443](https://github.com/danomation/Automation-Ragnarok-Script/assets/17872783/1efc1cac-f448-41d5-afd3-0dde521a8015)  
steps for solution:
1. install certbot, grab the cert, configure your /etc/nginx/sites-enabled/default and add a reverse proxy for location /roBrowserLegacy/client to proxy_pass http://grf.robrowser.com.
2. you must use your https cert for wss://. The wsproxy is set in the crontab you will need to use switches -s -c and -k. -c is your fullchain and -k is your privkey
3. edit your index.html, add a remoteClient field within your key values pointing to your webserver path for https://yourserver/roBrowserLegacy/client/.
4. also in your index.html change ws:// to wss://
5. close all tabs for the server in your browser, delete all cookies and site data, close browser, start browser back up and try.
6. if done correctly it should load the port 80 traffic for http://grf.robrowser.com as https://yourserver/roBrowserLegacy/client instead. 


# Video:  

[![ragnarokonline_oneclick](https://img.youtube.com/vi/HSR538rZhXM/0.jpg)](https://www.youtube.com/watch?v=HSR538rZhXM)  
donate for automation/scripting updates! https://www.patreon.com/Wintermute310  
