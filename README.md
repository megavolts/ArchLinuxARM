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
    fdisk /dev/mmcblkp0
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
    mount /dev/sdX1 boot
```

Create and mount the ext4 filesystem:
```
    mkfs.ext4 /dev/mmcblkpXs2
    mkdir root
    mount /dev/sdX2 root
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
Insert the SD card into the Raspberry Pi, connect ethernet, and apply 5V power.

Login as the default user alarm with the password alarm.

The default root password is root.

## 1. Configuration
Within the same wired network, get the IP address from the MAC:
```
    sudo arp-scan -q -l --interface enp0s25 | grep b8:27:eb:01:bd:78
```
The command return XXX.XXX.XXX.XXX  b8:27:eb:01:bd:78

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
    useradd -m -g users -G wheel,locate,network -s /bin/bash megavotls
    userdel alarm
```
Creating a new passowrd for megavolts
```
    passwd megavolts
```
Enter the passward twice

#### SSH config
Modifying ssh config
```
    nano -w /etc/ssh/sshd_config
```
1. Changin port ```Port 1354```
2. Adding ```Protocol 2```
3. Forbidding root login ```PermitRootLogin no```

Restart ssh config
```
    systemctl daemon-reload
```
Login as megavolts and enter root
```
    ssh megavolts@137.229.94.166 -p 1354
    su
```

### 1.1 Update system and keyring
Install random  number generator and archlinux-keyring
```
    pacman -S haveged archlinux-keyring
```
Initiate keyring with palliating the low-entropy issue
```
        haveged -w 1024
        pacman-key --init
        pkill haveged
        pacman-key --populate archlinux
```
Update the whole system
```
    pacman -Syu
```

### 1.2 Configuration
Install zsh and set it as default for root
```
    pacman -S grml-zsh-config
    chsh -s $(which zsh)
```
Logout and login to change the shell

Change console font
```
    echo 'FONT=Lat2-Terminus16' > /etc/vconsole.conf
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
    nano -w /etc/hosts
```
Add kiska after localhost.

Disable ipv6 by
1. Modifying the hosts file:
   ```
          nano -w /etc/hosts
   ```
   And commenting out ```#::1 ...```
2. Disabling ipv6 in ```/etc/sysctl.d/ipv6.conf```
   ```
       echo 'net.ipv6.conf.all.disable_ipv6=1' > /etc/sysctl.d/ipv6.conf
       echo 'net.ipv6.conf.eth0.disable_ipv6=1' >> /etc/sysctl.d/ipv6.conf
       echo 'net.ipv6.conf.wlan0.disable_ipv6=1' >> /etc/sysctl.d/ipv6.conf
    ```

### 1.3 Install essential package:
``` 
    pacman -S mlocate ntp htop binutils fakeroot make
    updatedb
```

### 1.4 Configuring i2c
Add the following line into ```/boot/config.txt```
```
    device_tree=bcm2708-rpi-b.dtb
    device_tree_param=i2c1=on
    device_tree_param=spi=on
```

### 1.5 Read-only root and boot
Adjust ```/etc/fstab```
```
    nano -w /etc/fstab
```
Add the following lines up to the ```#end``` and comment the first line
```
#/dev/mmcblk0p1  /boot           vfat    defaults        0       0
/dev/mmcblk0p1  /boot   vfat    defaults,ro,errors=remount-ro        0       0
tmpfs   /var/log    tmpfs   nodev,nosuid    0   0
tmpfs   /var/tmp    tmpfs   nodev,nosuid    0   0
#end
```
Adjust journald service to not log the system log to prevent flooding of the /var/log folder
```
    nano /etc/systemd/journald.conf
```
Uncomment and set "Storage=none"

Set root partition as read-only
```
    nano /boot/cmdline.txt
```
Replace the "rw" flag with the "ro" flag after the "root=" parameter

Disable systemd services
```
    systemctl disable systemd-random-seed
```
Create shortcut shell scripts to re-enable read-write temporarily if needed
```
    printf "mount -o remount,rw /\nmount -o remount,rw /boot" > /bin/writeenable
    printf "mount -o remount,ro /\nmount -o remount,ro /boot" > /bin/readonly
    chmod +x /bin/writeenable
    chmod +x /bin/readonly
```

Reboot, log and enter root

## 2 Time and RTC module
### 2.1 Update timezone:
```
    timedatectl set-timezone America/Anchorage
    ntpd -qg
    timedatectl status
```

### 2.2 Install
Check presence of RTC module
```
```
## 3 Monitorix
I use [monitorix](https://wiki.archlinux.org/index.php/Monitorix)
### 3.1 Installation
As non-root user, install monitorix
```
packer -S monitorix
```
### 3.2 Configuration
Log as root, enable the default buildt-in lightweight webserver and change the port
```
nano /etc/monitorix/monitorix.conf
```
Change the title, enable the default build-in lightweight webserver and change the port
```
....
title = Kiska Router
....
<httpd_builtin>
        enabled = y
        host =
        port = 8113
....
<graph_enable>
....
        raspberry_pi = y
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
packer -S anything-sync-daemon
```
Configure anything-sync-daemon:
```
nano -w /etc/asd.conf
```
Modify accordingly:
```
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
### Source

```
