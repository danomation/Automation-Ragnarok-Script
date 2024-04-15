# Update!! 
UI issues fixed! Change made: Adjusted packetversion to work with the default remote client  

# ragnarokonline_oneclick
webclient+server for Ubuntu 22.04. This script does very little but it can make a server in 12 minutes or so. 
It's just a bash that automates installation of several things.  
None of the ragnarok online files are hosted by this github. It is only an automation piece for educational purposes. Please respect copyright laws  

# Instructions:
Fresh Ubuntu 22.04, open root, and type in command:  
1. ```git clone https://github.com/danomation/ragnarok_script.git && bash ragnarok_script/ragnarok.sh  ```
2. Wait for server to install 15-20mins then navigate to http:// youriphere/ 

or use cloud-init (Not working yet):  
```
#cloud-config

write_files:
  - path: /run/scripts/oneclick.sh
    content: |
      #!/bin/bash
      git clone https://github.com/danomation/ragnarok_script.git && bash ragnarok_script/ragnarok.sh     
    permissions: '0755'

runcmd:
  - [ sh, "/run/scripts/oneclick.sh" ]

```
# Known issues:
1. First sign-on you can't make characters or login. 
Solution: shift+F5 to refresh the client and try again 

# Video:  

[![ragnarokonline_oneclick](https://img.youtube.com/vi/HSR538rZhXM/0.jpg)](https://www.youtube.com/watch?v=HSR538rZhXM)  
donate for automation/scripting updates! https://www.patreon.com/Wintermute310  
