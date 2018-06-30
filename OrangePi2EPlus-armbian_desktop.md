# Properties
* router + plex media player
* hostanme: kiska
* wlan0: HWMac 12:81:c6:e7:c5:62
* eth0: HWMac 02:81:c6:e7:c5:62
* Armbian: headless debian-bases server

Image can be found at http://www.orangepi.org/downloadresources/.

# Emmc installed
Extract the archive
```
7za e Armbian_5.38_Orangepiplus2e_Debian_stretch_next_4.14.14.7z
```
As root, copy image to SD card and sync
```
sudo dd if=Armbian_5.38_Orangepiplus2e_Debian_stretch_next_4.14.14.img of=/dev/mmcblk0 && sync
```
Boot the orangepi with the SD card. After login as root (root:1234), follow the initialisation step and create `megavolts` user.

Then update the system
```
apt update
apt upgrade
reboot
```
Install os on the emmc with, and follow the instruction
```
sudo nand-sata-install
```
Turn off the Orange, remove the SD card from the drive, and turn on the Orange which will reboot to eMMC.


# Configuration
## armbian-config
Run the `armbian-config` utils with:
```
armbian-config
```
And follow the menu to:
* System/Update firmware
* System/SSH: set `PermitRootLogin` to `no`
* System/minimal desktop (install minimal desktop with `plex` user autologin
* Personal/Timezone: America/Anchorage
* Personal/Hostaneme: kiska


# Install PlexMediaServer
Add the repositories and key, as root:
```
wget -O - https://dev2day.de/pms/dev2day-pms.gpg.key | sudo apt-key add -
echo "deb https://dev2day.de/pms/ stretch main" | sudo tee /etc/apt/sources.list.d/pms.list
apt-get update
```
Install plex and start the service as plex user
```
apt-get install plexmediaserver-installer
service plexmediaserver start
```

## Remote config
To set up plex remotely, create a ssh tunnel between the server and the host:
```
ssh 137.229.94.163 -L 8888:localhost:32400
```
In a webbrowser, configure plex media server at 'localhost:8888/web'

## Plex users
Modify plex user home direcotyr
```
cp /var/lib/plexmediaserver /home/plex  -R
chown plex:plex /home/plex -R
passwd plex <>
usermod -a -G audio,video,plugdev,systemd-journal,input,ssh plex
```
Set `plex` as autologin by default in `nano /etc/default/nodm`
```
NODM_USER=plex
```

## Firefox optimization
Install webbrowser and profile sync daemon
```
apt install firefox-esr profile-sync-daemon
```
Run profile-sync-daemon
```
psd
```
As `plex`, enable `firefox` and backup recovery in `home/plex/.config/psd/psd.conf`
```
USE_OVERLAYFS="yes"
BROWSERS="firefox"
USE_BACKUPS="yes"
BACKUP_LIMIT=5
```
Allow `plex` to `run psd-overlay-helper` as `root` without passowrd, modify `/etc/sudoers`:
```
plex ALL=(ALL) NOPASSWD: /usr/bin/psd-overlay-helper
```

Then start and test `'psd
```
systemctl --user start psd.service
psd p
systemctl --user enable psd.service

```
Tweak firefox performance according to ArchLinux


# SD card as storage
Format SD card as f2fs
```
mkfs.f2fs /dev/mmcblk0p1 
mkdir /mnt/data
```
Add to mountfs:
```
/dev/mmcblk0p1  /mnt/data       f2fs    defaults,nofail,x-systemd.device-timetout=1     0 2
```

Give write permission to `/mnt/data` to the group users
```
usermod -a -G users megavolts
usermod -a -G users plex
chown root:users /mnt/data -R
chmod 775 /mnt/data/ -R
```

# Configure AP/router
```
apt install hostapd dnsmasq bridge-utils
```
## Network interfaces
* bridge `br0` between `eth0` and `wlan0`
* NAT between `usb0` and `br0`
Edit `/etc/network/interfaces`:
```
source /etc/network/interfaces.d/*

# Wired adapter #1
auto eth0
allow-hotplug eth0
no-auto-down eth0
iface eth0 inet manual

# Wireless adapter #1
auto wlan0
allow-hotplug wlan0
no-auto-down wlan0
iface wlan0 inet manual

# Thethered usb connection
auto usb0
iface usb0 inet dhcp

# Local loopback
auto lo
iface lo inet loopback

# Bridge br0: eth0 <-> wlan0
auto br0
iface br0 inet static
        bridge_ports eth0 wlan0
        address 10.0.0.1
        netmask 255.255.255.0

pre-up iptables-restore < /etc/iptables.rules.usb0
        
```
Restart network
```
systemctl restart networking
```

## Hostpad
Adjust the option in `/etc/hostapd.conf`, especially `ssid` and `wpa_passphrase`:
```
interface=wlan0
bridge=br0

ssid=RedTrimCabin
driver=nl80211

hw_mode=g
channel=2

wpa=2
auth_algs=1

rsn_pairwise=CCMP
wpa_key_mgmt=WPA-PSK
wpa_passphrase=113Roxie          
```
Uncomment in `/etc/default/hostapd`
```
DAEMON_CONF="/etc/hostapd.conf"
```
Start and enable on success `hostapd.service`
```
systemctl start hostapd
systemctl enable hostapd
```

## Configure dnsmasq
Adjust the option in `/etc/dnsmasq.conf`, especially `interface` and `dhcp-range`:
```
# DNS server
server=8.8.8.8.8
server=8.8.4.4

interface=br0
dhcp-range=10.0.0.2,10.0.0.22,255.255.255.0,24h
```
If needed reserve some IP, in `/etc/dnsmas.conf
```
# IP reserved
# ulva, mediaserver
dhcp-host=30:85:A9:3C:4F:FE,10.0.0.11
```
Start the service `dnsmasq` and enable on success
```
systemctl start dnsmasq
systemctl enable dnsmasq
```

## Enable packet forwarding
For ipv4:
```
sysctl net.ipv4.ip_forward=1
```
And make the change persistant in `/etc/sysctl.d/30-ipforward.conf`
```
net.ipv4.ip_forward=1
net.ipv6.conf.default.forwarding=1
net.ipv6.conf.all.forwarding=1  
```

## Enable NAT:
Add the following IP tables rules:
```
iptables -t nat -A POSTROUTING -o usb0 -j MASQUERADE
iptables -A FORWARD -o usb0 -i br0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i br0 -o usb0 -j ACCEPT
```
Save the rules
```
iptables-save > /etc/iptables/iptables.hostapd
```

### Source:
* https://github.com/mripard/sunxi-mali
* https://github.com/mripard/sunxi-mali/issues/34
* http://linux-sunxi.org/Xorg#fbturbo_driver


# Source
* https://diyprojects.io/orange-pi-plus-2e-unpacking-installing-armbian-emmc-memory/

