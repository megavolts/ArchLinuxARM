* impossible to compile mali kernel driver *


kiska
* wlan0: HWMac 12:81:c6:e7:c5:62
* etho0: HWMac 02:81:c6:e7:c5:62
# 

Image can be found at http://www.orangepi.org/downloadresources/.
* Armbian: headless debian-bases server

# Emmc installed
Extract the archive
```
7za e Armbian_5.38_Orangepiplus2e_Debian_stretch_next_4.14.14.7z
```
As root, copy image to SD card and sync
```
sudo dd if=Armbian_5.38_Orangepiplus2e_Debian_stretch_next_4.14.14.img of=/dev/mmcblk0 && sync
```
Boot the orangepi with the SD card. After login as root (root:1234), follow the initialisation step.

Install os on the emmc with, and follow the instruction
```
sudo nand-sata-install
```
Turn off the Orange, remove the SD card from the drive, and turn on the Orange which will reboot to eMMC.
Then update the system
```
apt update
apt upgrade
reboot
```

# Configuration
## armbian-config
Run the `armbian-config` utils with:
```
armbian-config
```
And follow the menu to:
* System/Update firmware
* System/SSH: set `PermitRootLogin` to `no`
* Personal/Timezone: America/Anchorage
* Personal/Hostaneme: kiska
* .../minimal desktop


# Install PlexMediaServer
Add the repositories and key, as root:
```
wget -O - https://dev2day.de/pms/dev2day-pms.gpg.key | sudo apt-key add -
echo "deb https://dev2day.de/pms/ stretch main" | sudo tee /etc/apt/sources.list.d/pms.list
apt-get update
```
Install plex and start the service as plex user
```
apt-get install plexmediaserver-installer
service plexmediaserver start
```

## Remote config
To set up plex remotely, create a ssh tunnel between the server and the host:
```
ssh 137.229.94.163 -L 8888:localhost:32400
```
In a webbrowser, configure plex media server at 'localhost:8888/web'

## Plex users
Modify plex user home direcotyr
```
cp /var/lib/plexmediaserver /home/plex  -R
chown plex:plex /home/plex -R
passwd plex <>
usermod -a -G audio,video,plugdev,systemd-journal,input,ssh plex
```
Set `plex` as autologin by default in `nano /etc/default/nodm`
```
NODM_USER=plex
```

## Firefox optimization
## Install profile-sync-daemon
As root
```
apt install profile-sync-daemon
```
As `plex`, enable `chromium` and backup recovery in `home/plex/.config/psd/psd.conf`
```
USE_OVERLAYFS="yes"
BROWSERS="chromium"
USE_BACKUPS="yes"
BACKUP_LIMIT=5
```
Allow `plex` to `run psd-overlay-helper` as `root` without passowrd, modify `/etc/sudoers`:
```
plex ALL=(ALL) NOPASSWD: /usr/bin/psd-overlay-helper
```

Then start and test `'psd
```
systemctl --user start psd.service
psd -p
```


# SD card as storage
Format SD card as f2fs
```
mkfs.f2fs /dev/mmcblk0p1 
mkdir /mnt/data
```
Add to mountfs:
```
/dev/mmcblk0p1  /mnt/data       f2fs    defaults,nofail,x-systemd.device-timetout=1     0 2
```


Give write permission to `/mnt/data` to the group users
```
usermod -a -G users megavolts
usermod -a -G users plex
chown root:users /mnt/data -R
chmod 775 /mnt/data/ -R
```




### Source:
* https://github.com/mripard/sunxi-mali
* https://github.com/mripard/sunxi-mali/issues/34
* http://linux-sunxi.org/Xorg#fbturbo_driver


# Source
* https://diyprojects.io/orange-pi-plus-2e-unpacking-installing-armbian-emmc-memory/


