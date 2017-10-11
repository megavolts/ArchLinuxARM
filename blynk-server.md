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
### 1.2 Create self-signed SSL certificate
The router being not connected to internet, we generate self-signed certificate and key. Otherway, one can use 'Let's Encrypt SSL solution'
```
openssl req -x509 -nodes -days 1825 -newkey rsa:2048 -keyout blynk.key -out blynk.crt
```
Reply to the quesitons, then convert blynk.key to PKCS#8 private key:
```
openssl pkcs8 -topk8 -inform PEM -outform PEM -in blynk.key -out blynk.pem
```
Enter a password, copy the certificate and keys to cert subdirectory
```
mkdir certs
mv blynk.* /certs/
```

### 1.3 Configure and start blynk server
Download a copy of server.properties
```
wget https://raw.githubusercontent.com/megavolts/ArchRouter/master/opt/blynk/server.properties
```
Try the server with default setting by issuing:
```
java -jar server-0.28.2-java8.jar -serverConfig server.properties
```
The output should looks like:
```
  Blynk Server successfully started.
  All server output is stored in current folder in 'logs/blynk.log' file.
```

### 1.4 Create service to start at boot



## Source:
*[blynk github](https://github.com/blynkkk/blynk-server)
*[blynk website](https://www.blynk.cc/)
