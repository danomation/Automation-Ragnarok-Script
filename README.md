# Update!! 
UI issues fixed! Change made: Adjusted packetversion to work with the default remote client  

# Ragnarok Online Server+Client  
webclient+server for Ubuntu 22.04. This script does very little but it can make a server in 12 minutes or so. 
It's just a bash that automates installation of several things.  
None of the ragnarok online files are hosted by this github. It is only an automation piece for educational purposes. Please respect copyright laws  

# Instructions:
Fresh Ubuntu 22.04, open root, and type in command:  
1. ```git clone https://github.com/danomation/ragnarok_script.git && bash ragnarok_script/ragnarok.sh  ```
2. Wait for server to install 15-20mins then navigate to http:// youriphere/ 
3. Allow incoming ports TCP 80, 5999 
---
or use cloud-init:  
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
# Known issues:  
1. First sign-on you can't make characters or login. 
Solution: shift+F5 to refresh the client and try again  

# Video:  

[![ragnarokonline_oneclick](https://img.youtube.com/vi/HSR538rZhXM/0.jpg)](https://www.youtube.com/watch?v=HSR538rZhXM)  
donate for automation/scripting updates! https://www.patreon.com/Wintermute310  
