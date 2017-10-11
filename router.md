# Router
Step by step router configuration, using netctl to manage the bridge network, hostpad to generate the accesspoint, dnsmas to act as dhcp server and iptable to manage the connection.

## 0. Network setup

* eth0 : wired connection to the media center

* wlan0 : wireless access point "RedTrim"

* usb0 : therered internet connection from a smartphone

## 1. Installation
Install the packages
```
pacman -S hostapd dnsmasq iptables netctl
```

## 2. Create a network bridge
wlan0, eth0 and when available usb0 are united
```
cd /etc/systemd/network/
wget https://raw.githubusercontent.com/megavolts/ArchRouter/master/ressources/netctl/usb0.network
wget https://raw.githubusercontent.com/megavolts/ArchRouter/master/ressources/netctl/wlan0.network
```

## 2. Configuration
Copy default configuration files
```
cd /etc/hostapd
wget https://github.com/megavolts/ArchRouter/blob/master/ressources/hostapd.conf
```

```
## Source
* [bridge wiht systemd-networkd](https://wiki.archlinux.org/index.php/Systemd-networkd#Bridge_interface)

* 
