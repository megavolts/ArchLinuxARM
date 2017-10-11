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



## 1 Blynk
Create a directory for blynk server
```
mkdir /opt/blynk
cd /opt/blynk
```
Download last version of blynk for java8 from the [release page](https://github.com/blynkkk/blynk-server/releases)
```
wget https://github.com/blynkkk/blynk-server/releases/download/v0.28.2/server-0.28.2-java8.jar
```




## Source:
*[blynk github](https://github.com/blynkkk/blynk-server)
*[blynk website](https://www.blynk.cc/)
