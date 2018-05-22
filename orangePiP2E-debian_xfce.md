

# Linux distribution
Image can be found at http://www.orangepi.org/downloadresources/:
* ArmBian: impossible to compile mali kernel driver with 4.14.18
* Debian-Xfce

## Host:
* Orange Pi Plus 2E
* hostname: kiska
* wlan0: HWMac 12:81:c6:e7:c5:62
* etho0: HWMac 02:81:c6:e7:c5:62

## Emmc installion
After downloading the archive, extract the image:
```
tar -xvf OrangePi_Plus2E_Debian_Desktop_Xfce_v2.0.tar.gz
```
As root, copy image to SD card and sync
```
sudo dd if=OrangePi_Plus2E_Debian_Desktop_Xfce_v2.0.img of=/dev/mmcblk0 && sync
```
Boot the orangepi with the SD card. After login as root (root:1234), follow the initialisation step.

Install os on the emmc with, and follow the instruction
```
sudo nand-sata-install
```
Turn off the Orange, remove the SD card from the drive, and turn on the Orange which will reboot to eMMC.

