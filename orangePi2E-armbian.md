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

# Configuration
## armbian-config
Run the `armbian-config` utils with:
```
armbian-config
```
And follow the menu to:
* System/Update firmware
* System/SSH: set `PermitRootLogin` to `no`
* Personal/Timezone: America/Anchorage
* Personal/Hostaneme: kiska
Then reboot

## Install graphic server with mali kernel driver
Install dependencies
```
apt install xorg-dev xutils-dev x11proto-dri2-dev libltdl-dev libtool libltdl-dev libtool automake libdrm-dev libgl1-mesa-dri mesa-utils mesa-utils-extra mesa-common-dev libegl1-mesa-dev libxrandr-dev libx11-dev libgl1-mesa-dev
```
To compile `mali` with `USING_UMP=0`, `libump` and its dependencies `dri2` are needed

### dri2
```
git clone https://github.com/robclark/libdri2
cd libdri2/
autoreconf -i
./configure --prefix=/usr
make
make install
ldconfig
cd ..
```

### libump
Download sources
```
git clone https://github.com/linux-sunxi/libump
cd libump/
```
Build using `dpkg-buildpackage`
```
apt install autoconf libtool build-essential debhelper
dpkg-buildpackage -b
cd ..
apt install ./libump*...
```
or 
```
autoreconf -i
./configure --prefix=/usr
make
make install
cd ..
```

### Mali driver
Check if `CONFIG_CMA` and `CONFIG_DMA_CMA` are enabled in the kernel with
```
grep 'CONFIG_CMA' /boot/config-$(uname -r)
grep 'CONFIG_DMA_CMA' /boot/config-$(uname -r)
```
Install linux sources and unpack them, for 4.14.18 kernel
```
apt install linux-headers-next-sunxi linux-source-4.14.18-next-sunxi quilt
mkdir /usr/src/linux-source-4.14.18-sunxi
tar -xf /usr/src/linux-source-4.14.18-sunxi.tar.xz -C /usr/src/linux-source-4.14.18-sunxi
cp -r /usr/src/linux-headers-4.14.18-sunxi/* /usr/src/linux-source-4.14.18-sunxi/
```
Check kernel version in `/usr/src/linux-source-4.14.18-sunxi/include/generated/utsrelease.h` and '`/usr/src/linux-source-4.14.18-sunxi/include/config/kernel.release`. It should match the kernel version `4.14.18-sunxi`, otherwise modify it.

Build the kernel module after applying patch TODO STILL NOT WORKING
```
cd ~
git clone https://github.com/mripard/sunxi-mali.git
cd sunxi-mali
./build.sh -r r6p2 -a
make JOBS=4 USING_UMP=1 BUILD=release USING_PROFILING=0 MALI_PLATFORM=sunxi USING_DVFS=1 USING_DEVFREQ=1 KDIR=/usr/src/linux-source-4.14.18-sunxi CROSS_COMPILE=arm-linux-gnueabihf- -C ~/sunxi-mali/r6p2/src/devicedrv/mali
make JOBS=4 USING_UMP=0 BUILD=release USING_PROFILING=0 MALI_PLATFORM=sunxi USING_DVFS=1 USING_DEVFREQ=1 KDIR=/usr/src/linux-source-4.14.18-sunxi CROSS_COMPILE=arm-linux-gnueabihf- -C ~/sunxi-mali/r6p2/src/devicedrv/mali install
cd ..
```
Load the module
```
depmod
modprobe mali
```
Copy the blob 
```
git clone https://github.com/free-electrons/mali-blobs.git
cd mali-blobs
cp -a r6p2/fbdev/lib/lib_fb_dev/lib* /usr/lib
cp -a r6p2/fbdev/lib/lib_fb_dev/lib* /usr/lib/arm-linux-gnueabihf
cd ..
```
Set permission to mali:
```
echo "KERNEL==\"mali\", MODE=\"0660\", GROUP=\"video\"" > /etc/udev/rules.d/50-mali.rules
```

### Install fbturbo driver 

Build driver
```
git clone -b 0.4.0 https://github.com/ssvb/xf86-video-fbturbo.git
cd xf86-video-fbturbo
autoreconf -vi
./configure --prefix=/usr
make
make install
```
Configure Xorg Server
```
cp xorg.conf /etc/X11/xorg.conf.d/99-sunxifbturbo.conf
cd ..
```

### Install minimal XFCE
```
apt install xinit xserver-xorg xfwm4 xfce4-session xfce4-panel xfce4-settings  xfce4-terminal xfdesktop4  tango-icon-theme lightdm xfonts-base
systemctl enable lightdm
```
To set up autologin with lightdm, modify `/etc/lightdm/lightdm.conf`
```
[Seat:*]
pam-service=lightdm
pam-autologin-service=lightdm-autologin
session-wrapper=/etc/X11/Xsession
autologin-user=megavolts
autologin-user-timeout=0
autologin-session=xfce
```
LightDM goes through PAM even when autologin is enabled. You must be part of the autologin group to be able to login automatically without entering your password:
```
groupadd -r autologin
usermod -a -G autologin megavolts
```
Enabling interactive passwordless login, by configure PAM of lightdm `/etc/pam.d/lightdm`
```
#%PAM-1.0
# Allowing autologin group user to log without password
auth        sufficient  pam_succeed_if.so user ingroup autologin
auth        include     system-login
...
```
Then reboot. To verify, check if the correct driver (`FBTURBO`) is loaded in `/var/log/Xorg.0.log` in a X session
```
...
(II) Module fbturbo: vendor="X.Org Foundation"
   compiled for 1.12.4, module version = 0.4.0
   Module class: X.Org Video Driver
   ABI class: X.Org Video Driver, version 12.1
(II) FBTURBO: driver for framebuffer: fbturbo
(--) using VT number 7
...
```
Check and es acceleration with
```
es2gears
glxgears
es2_infos
glxinfos
```

## Essential packages
```
apt install mlocate firefox-esr
updatedb
```

# Media Center
## Install libdvpau-sunxi
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
## Install PlexMediaPlayer
Install dependencies
```
apt install autoconf automake libtool libharfbuzz-dev libfreetype6-dev libfontconfig1-dev   libvdpau-dev libva-dev  yasm libasound2-dev libpulse-dev libuchardet-dev zlib1g-dev libfribidi-dev git  libsdl2-dev cmake libgnutls28-dev libgnutls30
```
Compile and install mpv and ffmpeg
```
git clone https://github.com/mpv-player/mpv-build.git
cd mpv-build
echo --enable-libmpv-shared > mpv_options
./rebuild -j4
./install
ldconfig
cd ..
```
Install Qt5>5.10
```
apt-get install build-essential libfontconfig1-dev libdbus-1-dev libfreetype6-dev libicu-dev libinput-dev libxkbcommon-dev libsqlite3-dev libssl-dev libpng-dev libjpeg-dev libglib2.0-dev
```
Download and extract the source for QT5
```
wget http://download.qt.io/official_releases/qt/5.10/5.10.0/single/qt-everywhere-src-5.10.0.tar.xz
tar xf qt-everywhere-src-5.10.0.tar.xz
cd /tmp/qt-everywhere-opensource-src-%VERSION%
./configure
mkdir build && cd build
make
make install
```
Install qt5-dependencies
```
apt install qt5-default qtwebengine5-dev libqt5webchannel5-dev libqt5x11extras5-dev qtwebengine5-dev qml-module-qtquick-controls qml-module-qtwebengine qml-module-qtwebchannel libqt5sensors5-dev qt[psotopmomg5-dev 
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
service plexmediaserver start
```

## Remote config
To set up plex remotely, create a ssh tunnel between the server and the host:
```
ssh 137.229.94.163 -L 8888:localhost:32400
```
In a webbrowser, configure plex media server at 'localhost:8888/web'

### Sources
* https://github.com/plexinc/plex-media-player

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




### Source:
* https://github.com/mripard/sunxi-mali
* https://github.com/mripard/sunxi-mali/issues/34
* http://linux-sunxi.org/Xorg#fbturbo_driver


# Source
* https://diyprojects.io/orange-pi-plus-2e-unpacking-installing-armbian-emmc-memory/

# Install libdvpau-sunxi
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
ldconfig
# ln -s /usr/lib/arm-linux-gnueabihf/vdpau/libvdpau_sunxi.so.1 /usr/lib/libvdpau_nvidia.so
cd ..
```

ttf-dejavu 
ttf-dejavu 
ttf-dejavu libgl1-mesa-dri

# Create Plex User
```
useradd -m -g users -G autologin,audio -s /bin/sh plex
usermod -a -G autologin plex
passwd plex
113Roxie
```
Change plex direcotry from `/var/lib/plexmediaplayer` to `/home/plex` in `/etc/passwd` and move the entire directory
```
mv -v /var/lib/plexmediaplayer/* /home/plex/
```
Modify autologin in `/etc/lightdm/lightdm.conf`
```
autologin-user=plex
```

# Optimize chromium
## Install profile-sync-daemon
As root
```
apt install profile-sync-daemon
```
As `plex`, enable `chromium` and backup recovery in `home/plex/.config/psd/psd.conf`
```
USE_OVERLAYFS="yes"
BROWSERS="chromium"
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
psd -p
```
