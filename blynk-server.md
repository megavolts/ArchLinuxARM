# Blynk Server

## 0 Prerequisite
### 0.1 Install Java
For Rasberry Pi, model A, B, A+, B+ and zero. Java version up to 8 is supported.
```
pacman -S jre8-openjdk-headless 
```

### 0.2 Create data diretory
Data, logs are stored on a separate partition, with mmcblkX the sd card
```
fdisk /dev/mmcblk0
```
1. Type n, then p for primary, 3 for the second partition on the drive, press ENTER to accept the default first sector, then type +4G for the last sector.
2. Write the partition table and exit by typing w.
Foramt to ext4 and create mountpoint
```
mkfs.ext4 /dev/mmcblkXp3
mkdir /mnt/data
```
Modifiy the fstab accordingly and remount all
```
echo "/dev/mmcblk0p3 /mnt/data ext4 defaults 0 1" >> /etc/fstab 
mount -a
```
Create blynk data directory
```
mkdir /mnt/data/blynk
```

## 1 Blynk
### 1.1 Install with default settings
Create a directory for blynk server
```
mkdir /opt/blynk
cd /opt/blynk
```
Download last version of blynk for java8 from the [release page](https://github.com/blynkkk/blynk-server/releases)
```
wget https://github.com/blynkkk/blynk-server/releases/download/v0.28.2/server-0.28.2-java8.jar
```
Try the server with default setting by issuing:
```
java -jar server-0.28.2-java8.jar -dataFolder /mnt/data/blynk
```
The output should looks like:
```
  Blynk Server successfully started.
  All server output is stored in current folder in 'logs/blynk.log' file.
```
### 1.2 Advanced setup
#### 1.2.1 'Let's Encrypt' SSL Certificate generation
Install certbot
```
pacman -S certbot
```


## Source:
*[blynk github](https://github.com/blynkkk/blynk-server)
*[blynk website](https://www.blynk.cc/)
