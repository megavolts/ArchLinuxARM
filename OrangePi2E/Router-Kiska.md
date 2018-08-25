# Orange Pi 2E+
## Properties
* router + plex media player
* hostanme: kiska
* wlan0: HWMac 12:81:c6:e7:c5:62
* eth0: HWMac 02:81:c6:e7:c5:62
* Armbian: headless debian-bases server

## Armbian Stretch
Image can be found at http://www.orangepi.org/downloadresources/.

### Install on SD
Download and extract the archive
```
wget https://dl.armbian.com/orangepiplus2e/Debian_stretch_next.7z
7za e Debian_stretch_next.7z
```
As root, copy image to SD card and sync
```
sudo dd if=Armbian_5.59_Orangepiplus2e_Debian_stretch_next_4.14.65.img of=/dev/mmcblk0 && sync
```
Boot the orangepi with the SD card. After login as root (root:1234), follow the initialisation step.

### Initial config:
First, update the system
```
apt update
apt upgrade
reboot
```
Run the `armbian-config` utils with:
```
armbian-config
```
And follow the menu to:
* System/Update firmware
* System/SSH: set `PermitRootLogin` to `no`
* System/minimal desktop
* Personal/Timezone: America/Anchorage
* Personal/Hostaneme: kiska

Reboot

##

