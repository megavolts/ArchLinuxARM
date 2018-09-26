# RaspberryPiZero



## Install and configure debian

Download latest image
```
wget -O raspbian_latest.zip https://downloads.raspberrypi.org/raspbian_lite_latest
```
Unzip and copy image on sd card
```
unzip -p raspbian_latest.zip | sudo dd of=/dev/mmcblk0 bs=4M conv=fsync status=progress
sync
```
### Configure the image
Mount locally the sd card.
```
mkdir /mnt/armbian
mount /dev/mmcblk0p2 /mnt/armbian
cd /mnt/armbian
```
#### Configure network
Add wireless configuration in `etc/network/interfaces/':
```
auto wlan0
allow-hotplug wlan0
iface wlan0 inet dhcp
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
```
Modifiy '/etc/wpa_supplicant/wpa_supplicant.conf:
```
network={
  ssid="RedTrim"
  psk="113RoxieRd"
  proto=RSN
  key_mgmt=WPA-PSK
  pairwise=CCMP
  auth_alg=OPEN
}
Unmount:
```
cd
umount /mnt/armbian
```

#### Enable `ssh`
To enable `ssh` add an empty file named ssh in the boot directory
```
mount /etc/mmcblk0p1 /mnt/armbian
touch /mnt/armbian/ssh
umount /mnt/armbian
```

Boot the RaspberryPi Zero after setting up the SD card and log via ssh.

## Set up the Raspberry Pi:
To find the IP of the RaspberryPi, use nmap and remotely log via ssh (pi:password:
```
nmap -p22 -sV 192.168.0.0/24
ssh pi@10.42.0.91
```
Change default password for pi and root:
```
passwd
sudo su
passwd
```
Upgrade the system
```
apt update
apt upgrade
```

### Micropyton
To build micropython from sources, install dependencies:
```
apt install -y git build-essential libffi-dev
```
Clone micropython:
```
cd ~
git clone https://github.com/micropython/micropython.git
cd micropython/ports/unix
make clean
make axtls
make
make install
```
### DHT for micropython



### DHT for python
```
apt -y install build-essential python-dev python-openssl git
git clone https://github.com/adafruit/Adafruit_Python_DHT.git
cd Adafruit_Python_DHT
python setup.py install
