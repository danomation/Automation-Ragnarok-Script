# Automation Script for RO Server + Web Client
It is only an automation piece to for educational purposes. Please respect copyright laws.  
This script automates a complicated install in 12 minutes or so. 
It's just a bash that automates installation of several things.  
None of the ragnarok online files are hosted by this github.  

The ragnarok web client was not created by me. It can be found at https://github.com/MrAntares/roBrowserLegacy  
Their discord is https://discord.gg/8JdHwM4Kqm  

# Instructions REQUIRES Ubuntu 22.04:
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

# Video:  

[![ragnarokonline_oneclick](https://img.youtube.com/vi/HSR538rZhXM/0.jpg)](https://www.youtube.com/watch?v=HSR538rZhXM)  
donate for automation/scripting updates! https://www.patreon.com/Wintermute310  
