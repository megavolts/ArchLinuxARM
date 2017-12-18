# Router
Step by step router configuration, using netctl to manage the bridge network, hostpad to generate the accesspoint, dnsmas to act as dhcp server and iptable to manage the connection.

## 0. Network setup

* eth0 : wired connection to the media center

* wlan0 : wireless access point "RedTrim"

* usb0 : therered internet connection from a smartphone

## 1. Installation
Install the packages
```
pacman -S iptables netctl bridge-utils net-tools iproute2
```
Enable systemd-networkd
```
systemctl start systemd-networkd 
systemctl enable systemd-networkd 
```
Enable resolved abnd symlink   if the DNS are note managed in /etc/resolv.conf.
```
systemd-resolved.service
ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
```

## 2. Create bridge
```
cd /etc/systemd/network/
wget https://raw.githubusercontent.com/megavolts/ArchRouter/master/ressources/bridge/br0.netdev
```
Load br_netfilter module
```
modprobe br_netfilter
echo br_netfilter >> /etc/modules-load.d/bridge.conf
```
Add eth0, usb0, wlan0 to bridge and create bridge interface
```
rm eth0.network
wget https://raw.githubusercontent.com/megavolts/ArchRouter/master/ressources/bridge/wlan0.network
wget https://raw.githubusercontent.com/megavolts/ArchRouter/master/ressources/bridge/eth0.network
wget https://raw.githubusercontent.com/megavolts/ArchRouter/master/ressources/bridge/usb0.network
wget https://raw.githubusercontent.com/megavolts/ArchRouter/master/ressources/bridge/br0.network
```
## 3. Create Access Point
Install hostapd
```
pacman -S hostapd
```
Download hostapd configuraiton to /etc/hostapd
```
cd /etc/hostapd/
wget https://github.com/megavolts/ArchRouter/raw/master/ressources/hostapd/hostapd.conf
```
Bring wireless network interface up
```
ip link set dev wlan0 up
```
Start and enable dnsmasq service
```
systemctl start hostapd
systemctl status hostapd
```
If nothing is wrong, enable the service at boot
```
systemctl enable hostapd
```

## 4. Use dnsmas as dhcp server
Install dnsmasq
```
pacman -S dnsmas
```
Download dnsmasq configurationt to /etc/
```
wget https://github.com/megavolts/ArchRouter/raw/master/ressources/dnsmasq.conf -p /etc/dnsmasq.conf
```
Start and enable dnsmasq service
```
systemctl start dnsmasq
systemctl status dnsmasq
```
If nothing is wrong, enable the service at boot
```
systemctl enable dnsmasq
```
## 5. Configure iptables
Install iptables
```
pacman -S iptables
```
Enable ip forwarding and make it stick at boot
```
sysctl net.ipv4.ip_forward=1  
echo net.ipv4.ip_forward=1 >> /etc/sysctl.d/ipforward.conf
```
Download iptables run
```
cd /etc/iptables/iptables.rules
wget https://github.com/megavolts/ArchRouter/raw/master/ressources/iptables/iptables.rules
```
Enable NAT
```
iptables -t nat -A POSTROUTING -o usb0 -j MASQUERADE
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i br0 -o usb0 -j ACCEPT
```
Save the rules
```
iptables-save > /etc/iptables/iptables.conf
```
Start and enable iptables
```
systemctl start iptables
systemctl enable iptables
```
Restart systemd-networkd
```
``



## Source
* [hostapd access point] (https://wiki.archlinux.org/index.php/software_access_point)

* [bridge wiht systemd-networkd](https://wiki.archlinux.org/index.php/Systemd-networkd#Bridge_interface)

* 
