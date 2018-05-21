kiska
* wlan0: HWMac 12:81:c6:e7:c5:62
* etho0: HWMac 02:81:c6:e7:c5:62
#
Debian Stretch
kiska

### Change hostname
Change hostname in `/etc/hostname`:
```
echo kiska > /etc/hostname
```
Add `kiska` to `/etc/hosts`:




Give write permission to `/mnt/data` to the group users
```
usermod -a -G users megavolts
usermod -a -G users plex
chown root:users /mnt/data -R
chmod 775 /mnt/data/ -R
```


### SD card as storage
Format SD card as f2fs
```
mkfs.f2fs /dev/mmcblk0p1 
mkdir /mnt/data
```
Add to mountfs:
```
/dev/mmcblk0p1  /mnt/data       f2fs    defaults,nofail,x-systemd.device-timetout=1     0 2
```
### Harden ssh
MOdifiy `/etc/ssh/sshd_config`:
```
PermitRootLogin no 
```

## Plex server
### Install plex
Add the repositories and key:
```
wget -O - https://dev2day.de/pms/dev2day-pms.gpg.key | sudo apt-key add -
echo "deb https://dev2day.de/pms/ jessie main" | sudo tee /etc/apt/sources.list.d/pms.list
apt-get update
```
Install plex and start the service as plex user
```
apt-get install plexmediaserver-installer
service plexmediaserver restart
```

### Add file to server
Create ssh tunnel between kiska and computer
```
ssh 137.229.94.163 -L 8888:localhost:32400
```
In a webbroser
```
localhost:8888/web
```
