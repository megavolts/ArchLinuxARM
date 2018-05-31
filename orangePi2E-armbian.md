* impossible to compile mali kernel driver *


kiska
* wlan0: HWMac 12:81:c6:e7:c5:62
* etho0: HWMac 02:81:c6:e7:c5:62
# 

Image can be found at http://www.orangepi.org/downloadresources/.
* Armbian: headless debian-bases server

# Emmc installed
Extract the archive
```
7za e Armbian_5.38_Orangepiplus2e_Debian_stretch_next_4.14.14.7z
```
As root, copy image to SD card and sync
```
sudo dd if=Armbian_5.38_Orangepiplus2e_Debian_stretch_next_4.14.14.img of=/dev/mmcblk0 && sync
```
Boot the orangepi with the SD card. After login as root (root:1234), follow the initialisation step.

Install os on the emmc with, and follow the instruction
```
sudo nand-sata-install
```
Turn off the Orange, remove the SD card from the drive, and turn on the Orange which will reboot to eMMC.
Then update the system
```
apt update
apt upgrade
reboot
```

# Mali driver
## Mali Kernel Module
Check if `CONFIG_CMA` and `CONFIG_DMA_CMA` are enabled in the kernel with
```
grep 'CONFIG_CMA' /boot/config-$(uname -r)
grep 'CONFIG_DMA_CMA' /boot/config-$(uname -r)
```
Install the linux source and unpack them, for 4.14.18 kernel
```
apt install linux-source-4.14.18-next-sunxi quilt
mkdir /usr/src/linux-source-4.14.18-sunxi
tar -xf /usr/src/linux-source-4.14.18-sunxi.tar.xz -C /usr/src/linux-source-4.14.18-sunxi
```
Check kernel version in `/usrs/src/linux-source-#VERSION/include/generated/utsrelease.h` and '`/usrs/src/linux-source-#VERSION/include/config/kernel.release`. It should match the kernel version 4.14.18

Build the kernel module after applying patch (./build.sh -r r6p2 -a)
```
cd ~
git clone https://github.com/mripard/sunxi-mali.git
cd sunxi-mali
export CROSS_COMPILE=arm-linux-gnueabihf-
export KDIR=/usr/src/linux-source-4.14.18-sunxi
# export INSTALL_MOD_PATH=/lib/modules/4.14.18-sunxi/extra/
./build.sh -r r6p2 -b
./build.sh -r r6p2 -i 
```
If `./build.sh -r r6p2 -b` failed, use
```
./build.sh -r r6p2 -a
make -j 4 USING_UMP=0 BUILD=release USING_PROFILING=0 MALI_PLATFORM=sunxi USING_DVFS=1 USING_DEVFREQ=1 KDIR=/usr/src/linux-source-4.14.18-sunxi CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=/lib/modules/4.14.18-sunxi/extra/ -C /usr/src/linux-source-4.14.18-sunxi
make JOBS=4 USING_UMP=0 BUILD=release USING_PROFILING=0 MALI_PLATFORM=sunxi USING_DVFS=1 USING_DEVFREQ=1 KDIR=/usr/src/linux-source-4.14.18-sunxi CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=/lib/modules/4.14.18-sunxi/extra/ -C ~/sunxi-mali/r6p2/src/devicedrv/mali install
```
Load the module
```
modprobe mali
```
Copy the blob 
```
git clone https://github.com/free-electrons/mali-blobs.git
cd mali-blobs
cp -a r6p2/fbdev/lib/lib_fb_dev/lib* /usr/lib
```

### Source:
* https://github.com/mripard/sunxi-mali
* https://github.com/mripard/sunxi-mali/issues/34


# Configuration
## Harden security
Change ssh settings, in `/etc/ssh/sshd_config`,
- set `PermitRootLogin` to `no` 

## Update system to buser
Change debian version from `stretch` to `buster` to enable qt5 => 5.9
```
nano -w /etc/apt/sources.list
-----------------------------
deb http://httpredir.debian.org/debian buster main contrib non-free

deb http://httpredir.debian.org/debian buster-updates main contrib non-free

deb http://security.debian.org/ buster/updates main contrib non-free
```
Then update the system
```
apt update
apt upgrade
reboot
```
Run the armbian-config utils with
```
armbian-config
```
And follow the menu to:
* System/Update firmware
* Personal/Timezone: America/Anchorage
* Personal/Hostaneme: kiska
Then reboot

## Essential packages
```
apt-get install mlocate
updatedb
```

## Install minimal graphic interface
Install dependencies
```
apt install xorg-xserver xinit
```
Install pekwm
```
apt-get install pekwm xterm
```
Create init file
```
nano -w ~/.xinitrc
-------------------
exec pekwm
```

# Media Center
## Install PlexMediaPlayer
Install dependencies
```
apt install autoconf automake libtool libharfbuzz-dev libfreetype6-dev libfontconfig1-dev libx11-dev libxrandr-dev libvdpau-dev libva-dev mesa-common-dev libegl1-mesa-dev yasm libasound2-dev libpulse-dev libuchardet-dev zlib1g-dev libfribidi-dev git libgl1-mesa-dev libsdl2-dev cmake libgnutls-28dev libgnutls30
```
Compile and install mpv and ffmpeg
```
git clone https://github.com/mpv-player/mpv-build.git
cd mpv-build
echo --enable-libmpv-shared > mpv_options
./rebuild -j4 (this steps checks out all sources and compiles them and takes a while)
./install
ldconfig
cd ..
```
Install qt5-dependencies
```
apt install qt5-default qtwebengine5-dev libqt5webchannel5-dev libqt5x11extras5-dev qtwebengine5-dev qml-module-qtquick-controls qml-module-qtwebengine qml-module-qtwebchannel
```
Compile and install plexmediaplayer (pmp)
```
git clone git://github.com/plexinc/plex-media-player
cd plex-media-player
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Debug -DQTROOT=/usr  -DCMAKE_INSTALL_PREFIX=/usr/local/ ..
make -j4
make install
cd ..
```

## Install PlexMediaServer
Add the repositories and key, as root:
```
wget -O - https://dev2day.de/pms/dev2day-pms.gpg.key | sudo apt-key add -
echo "deb https://dev2day.de/pms/ stretch main" | sudo tee /etc/apt/sources.list.d/pms.list
apt-get update
```
Install plex and start the service as plex user
```
apt-get install plexmediaserver-installer
service plexmediaserver restart
```
Set up plex remotely by creating a ssh tunnel between kiska and the computer
```
ssh 137.229.94.163 -L 8888:localhost:32400
```
In a webbrowser, configure plex media server at 'localhost:8888/web'

Symlink `libGLESv2` and `libBEGL` to `/usr/bin`
```
ln -s /usr/lib/arm-linux-gnueabihf/libGLESv2.so /usr/bin
ln -s /usr/lib/arm-linux-gnueabihf/libEGL.so /usr/bin
```
# Install Plex Media Player
https://github.com/plexinc/plex-media-player

### SD card as storage
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

#




### Add file to server
Create ssh tunnel between kiska and computer
```
ssh 137.229.94.163 -L 8888:localhost:32400
```
In a webbroser
```
localhost:8888/web
```


# Source
* https://diyprojects.io/orange-pi-plus-2e-unpacking-installing-armbian-emmc-memory/

# Remote X11 connection

## Compile libvdpau-sunxi
Install dependencies
```
apt install libpixman-1-dev
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
ln -s /usr/lib/arm-linux-gnueabihf/vdpau/libvdpau_sunxi.so.1 /usr/lib/libvdpau_nvidia.so

cd ..
```

