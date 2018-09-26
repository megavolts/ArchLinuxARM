# ArchLinuxARM


## 3 Monitorix
I use [monitorix](https://wiki.archlinux.org/index.php/Monitorix)
### 3.1 Installation
As non-root user, install monitorix
```
yaourt -S monitorix --noconfirm --needed
```
### 3.2 Configuration
Log as root, enable the default buildt-in lightweight webserver and change the port

```
nano /etc/monitorix/monitorix.conf
----
title = Kiska Router
hostname = Kiska
....
<httpd_builtin>
        enabled = y
        host =
        port = 8113
....
<graph_enable>
....
        raspberrypi = y
....
```
   
Start the service and check the journal by issuing 
```
systemctl start monitorix
systemctl status monitorix
```
If everythink looks good
```
systemctl enable monitorix
```

View the system stats via a webbrowser at IP:8113/monitorix. When running for the first time Monitroix, several minutes are necessary for the data collected to be displayed graphically.

### 3.3 Using tmpfs to store RRD databases
Install anyting-sync-daemon to reduce read/write on the sd card
```
yaourt -S anything-sync-daemon --noconfirm
```
Configure anything-sync-daemon:
```
nano -w /etc/asd.conf
-----
WHATTOSYNC=('/var/lib/monitorix') 
```
Start the service and check the journal by issuing 
```
systemctl start asd
systemctl status asd
```
If everythink looks good
```
systemctl enable asd
```
