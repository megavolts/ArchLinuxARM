# Router
Step by step router configuration

## 0. Network setup

* eth0 : wired connection to the media center

* wlan0 : wireless access point "RedTrim"

* usb0 : therered internet connection from a smartphone

## 1. Installation
Install hostapd to generate the accesspoint, iptables to forward connection between usb0, wlan0 and eth0
```
pacman -S hostapd dnsmasq iptables
```

## 2. Configuration
Copy default configuration files
```
cd /etc/hostapd
wget wget https://github.com/megavolts/ArchRouter/blob/master/ressources/hostapd.conf
```
