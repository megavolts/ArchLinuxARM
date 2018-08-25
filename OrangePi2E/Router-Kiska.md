# Orange Pi 2E+
## Properties
* router + plex media player
* hostanme: kiska
* wlan0: HWMac 12:81:c6:e7:c5:62
* eth0: HWMac 02:81:c6:e7:c5:62
* Armbian: headless debian-bases server

## Armbian Stretch
Image can be found at http://www.orangepi.org/downloadresources/.

### Install on SD
Download and extract the archive
```
wget https://dl.armbian.com/orangepiplus2e/Debian_stretch_next.7z
7za e Debian_stretch_next.7z
```
As root, copy image to SD card and sync
```
sudo dd if=Armbian_5.59_Orangepiplus2e_Debian_stretch_next_4.14.65.img of=/dev/mmcblk0 && sync
```
Boot the orangepi with the SD card. 

### Initial config:
After login as root (root:1234), follow the initialisation step.

First, update the system
```
apt update
apt upgrade
reboot
```
Run the `armbian-config` utils with:
```
armbian-config
```
And follow the menu to:
* System/Update firmware
* System/SSH: set `PermitRootLogin` to `no`
* System/minimal desktop
* Personal/Timezone: America/Anchorage
* Personal/Hostaneme: kiska
* Software/Headers
* Software/Full


Reboot

## Router configuration




## Essential packages
```
apt install mlocate
updatedb
```

## Install PMP
### Install libdvpau-sunxi
Install dependencies
```
apt install libpixman-1-dev libvdpau-dev
```
Compile libcedrus
```
git clone https://github.com/linux-sunxi/libcedrus.git
cd libcedrus
make
make install
cd ..
```
Set permission
```
echo "KERNEL==\"disp\", MODE=\"0660\", GROUP=\"video\"" > /etc/udev/rules.d/50-disp.rules
echo "KERNEL==\"cedar\", MODE=\"0660\", GROUP=\"video\"" > /etc/udev/rules.d/50-cedar_dev.rules
```
Compile libvdpau-sunxi
```
git clone https://github.com/linux-sunxi/libvdpau-sunxi.git
cd libvdpau-sunxi
make
make install
ldconfig
ln -s /usr/lib/arm-linux-gnueabihf/vdpau/libvdpau_sunxi.so.1 /usr/lib/libvdpau_nvidia.so
cd ..
``` 

### Compile mpv
Install dependencies
```
apt install autoconf automake libtool libharfbuzz-dev libfreetype6-dev libfontconfig1-dev libvdpau-dev libva-dev  yasm libasound2-dev libpulse-dev libuchardet-dev zlib1g-dev libfribidi-dev git libsdl2-dev cmake libgnutls28-dev libgnutls30
```
Compile `mpv` with `ffmpeg`
```
git clone https://github.com/mpv-player/mpv-build.git
cd mpv-build
echo --enable-libmpv-shared > mpv_options
./rebuild -j4
./install
ldconfig
cd ..
```

### Compile Qt5.9.5
```
apt install build-essential libfontconfig1-dev libdbus-1-dev libfreetype6-dev libicu-dev libinput-dev libxkbcommon-dev libsqlite3-dev libssl-dev libpng-dev libjpeg-dev libglib2.0-dev libjpeg-dev libasound2-dev pulseaudio libpulse-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
```


