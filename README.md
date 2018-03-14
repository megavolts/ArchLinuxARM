# ArchRouter
Router/Access Point installation on a Raspeberry Pi

eth0 MAC b8:27:eb:01:bd:78 

- hostpadd
- blynk server
- monitorix
- 

Read-only root/boot
Write-access to home/tmp/var

## 0. ArchLinux Installation on SD Card
Source: https://archlinuxarm.org/platforms/armv6/raspberry-pi
Replace mmcblkX in the following instructions with the device name for the SD card as it appears on your computer.

### 0.1 Create filesystem
Start fdisk to partition the SD card:
```
fdisk /dev/mmcblkp
```
At the fdisk prompt, delete old partitions and create a new one:
1. Type o. This will clear out any partitions on the drive.
2. Type p to list partitions. There should be no partitions left.
3. Type n, then p for primary, 1 for the first partition on the drive, press ENTER to accept the default first sector, then type +100M for the last sector.
4. Type t, then c to set the first partition to type W95 FAT32 (LBA).
5. Type n, then p for primary, 2 for the second partition on the drive, press ENTER to accept the default first sector, then type +4G for the last sector.
6. Write the partition table and exit by typing w.

Create and mount the FAT filesystem:
```
mkfs.vfat /dev/mmcblkpXs1
mkdir boot
mount /dev/mmcblkpXs1 boot
```

Create and mount the ext4 filesystem:
```
mkfs.ext4 /dev/mmcblkpXs2
mkdir root
mount /dev/mmcblkpXs2 root
```


### 0.2 Install ArchLinux system
Download and extract the root filesystem (as root, not via sudo):
```
wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
bsdtar -xpf ArchLinuxARM-rpi-latest.tar.gz -C root
sync
```
Move boot files to the first partition:
```
mv root/boot/* boot
```
Unmount the two partitions:
```
umount boot root
```

### 0.3 Boot and login
### 0.3.1 Remote Access
To display IP address at console login, add to boot/etc/issue, before unmoutning
```
IP: \4{eth0}
```
Within the same wired network, the IP address can be find by looking up the MAC address:
```
sudo arp-scan -q -l --interface enp0s25 | grep b8:27:eb:01:bd:78
```
The command should return:
```
XXX.XXX.XXX.XXX  b8:27:eb:01:bd:78
```
With `XXX.XXX.XXX.XXX` the IP address of the Pi.

Insert the SD card into the Raspberry Pi, connect ethernet, and apply 5V power.

Login either through console or via ssh. Default user:password is alarm:alaram; Root user is root:root.
Log via ssh to IP
```
ssh alarm@XXX.XXX.XXX.XXX 
```
Enter root
```
su
```

### 1.0 Improve security
#### Change password and user
Change the root password
```
passwd
```
Creat a new user (megavolts) and delete default user alarm
```
    useradd -m -g users -G wheel,network -s /bin/bash megavolts
```
Creating a new password for megavolts and logout
```
passwd megavolts
```
Install `sudo` and add `megavolts` do sudoers
```
pacman -S sudo
echo 'megavolts ALL=(ALL) ALL' >> /etc/sudoers
exit
exit
```
Login as megavolts and enter root, and delete user `alarm`
```
ssh megavolts@137.229.94.166
su
userdel alarm
```

### 1.1 Update system and keyring
Update the system
```
pacman -Syu
```
Install random  number generator and archlinux-keyring
```
pacman -S haveged archlinux-keyring
```
Initiate keyring with palliating the low-entropy issue with haveged
```
haveged -w 1024
pacman-key --init
pkill haveged
pacman-key --populate archlinux
pacman -Syu
```

### 1.2 Configuration
Change console font
```
echo 'FONT=Lat2-Terminus16' >> /etc/vconsole.conf
```
Enable only two virtual console
```
echo 'NautoVTS=2' >> /etc/systemd/logind.conf
```
Change hostname
```
echo kiska > /etc/hostname
```
And modify hosts file
```
echo kiska >> /etc/hosts
```
Disabling ipv6 in `/etc/sysctl.d/ipv6.conf`
```
echo 'net.ipv6.conf.all.disable_ipv6=1' > /etc/sysctl.d/ipv6.conf
echo 'net.ipv6.conf.eth0.disable_ipv6=1' >> /etc/sysctl.d/ipv6.conf
echo 'net.ipv6.conf.wlan0.disable_ipv6=1' >> /etc/sysctl.d/ipv6.conf
```

### 1.3 Install essential package:
``` 
pacman -S mlocate ntp htop binutils fakeroot make wget lsof strace
updatedb
```

### wifi dongle


### 1.4 Install i2c rtc clock
Run he scripts as root
```
wget https://raw.githubusercontent.com/megavolts/ArchRouter/master/ds1307_rtc.sh
chmod +x ds1307_rtc.sh
./ds1307_rtc.sh
```
Update the system time
```
systemctl stop ntpd
ntpd –dqg
```
Sync RTC with clock:
```
hwclock -f /dev/rtc0 –w
```
Change timezone
```
timedatectl set-timezone America/Anchorage
timedatectl status
```

### 1.y Install packer aur package manager
Install dependencies
```
pacman -S --needed --noconfirm curl git wget gcc yajl pkg-config sudo
```
Download and build package-query and yaourt, as non-root user
```
wget https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz
tar -xvzf package-query.tar.gz
cd package-query
makepkg -si
cd ..
wget https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz
tar -xvzf yaourt.tar.gz
cd yaourt
makepkg -si
cd ../
rm -rf package-query/ package-query.tar.gz yaourt/ yaourt.tar.gz
```

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
