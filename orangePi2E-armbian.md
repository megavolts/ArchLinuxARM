* impossible to compile mali kernel driver *


kiska
* wlan0: HWMac 12:81:c6:e7:c5:62
* etho0: HWMac 02:81:c6:e7:c5:62
# 

Image can be founda at http://www.orangepi.org/downloadresources/.
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

# Install linux-sunxi kernel
## Compile mali kernel driver
 Install corrs compiler
 ```
echo "deb http://emdebian.org/tools/debian/ stretch main" >>/etc/apt/sources.list.d/crosstools.list 
curl http://emdebian.org/tools/debian/emdebian-toolchain-archive.key | sudo apt-key add -
sudo dpkg --add-architecture armhf
sudo apt-get update
sudo apt-get install crossbuild-essential-armhf
```
Compile mali kernel driver
```
git clone https://github.com/mripard/sunxi-mali.git
cd sunxi-mali
export CROSS_COMPILE=$TOOLCHAIN_PREFIX
export KDIR=$KERNEL_BUILD_DIR
export INSTALL_MOD_PATH=$TARGET_DIR
./build.sh -r r6p2 -b
./build.sh -r r6p2 -i
```

Linux-sunxi kernel suppor HW decoding


# Configuration

## Essential packages
```
apt-get install mlocate
updatedb
```

## Update the system
```
apt-get update
apt-get upgrade
apt upgrade
reboot
```

## Harden ssh
Forbid root login via ssh
Modifiy `/etc/ssh/sshd_config`:
```
PermitRootLogin no 
```

## Setting up X-server
Install dependencies:
```
apt-get install git build-essential xorg-dev xutils-dev x11proto-dri2-dev libltdl-dev libtool automake xinit xerger-xorg
```
Install fbturbo
```
git clone -b 0.4.0 https://github.com/ssvb/xf86-video-fbturbo.git
cd xf86-video-fbturbo
autoreconf -vi
./configure --prefix=/usr
make
make install
```
Test xorg with pekwm
```
apt-get install pekwm
echo "exec pekwm" ~/.xinitrc
startx
```


NO NEED YET

### INstall the Unified Memory Provider (UMP)
Install dependencies
``` 
apt-get install git build-essential autoconf libtool debhelper dh-autoreconf fakeroot pkg-config
```
Clone and build packages after descending into the git tree
```
git clone https://github.com/linux-sunxi/libump.git
cd libump
dpkg-buildpackage -b
```
Install the package
```
dpkg -i ../libump_*.deb
```

### Install the Mali Userspace driver
Install dependencies
```
apt-get install automake xutils-dev
```
Clone the repositories
```
git clone --recursive https://github.com/linux-sunxi/sunxi-mali.git
cd sunxi-mali
```
Configure 
```
rm -f config.mk
```


## Compile mali graphical driver
Install dependencies:
```
apt-get install libx11-dev libxext-dev xutils-dev libdrm-dev x11proto-xf86dri-dev libxfixes-dev x11proto-dri2-dev xserver-xorg-dev build-essential automake pkg-config libtool ca-certificates git cmake subversion
```
Clone 3rd party packages:
```
mkdir mali
cd mali
git clone https://github.com/linux-sunxi/libump

git clone https://github.com/linux-sunxi/sunxi-mali
git clone https://github.com/robclark/libdri2
git clone https://github.com/ssvb/xf86-video-fbturbo
git clone https://github.com/ptitSeb/glshim
```
Compile libdr2:
```
cd libdri2/
autoreconf -i
./configure --prefix=/usr
make
make install
ldconfig
cd ..
```
Compile libump
```
cd libump/
autoreconf -i
./configure --prefix=/usr
make
make install
cd ..
```
Compile mali
```
cd sunxi-mali/
git submodule init
git submodule update
git pull
wget http://pastebin.com/raw.php?i=hHKVQfrh -O ./include/GLES2/gl2.h
wget http://pastebin.com/raw.php?i=ShQXc6jy -O ./include/GLES2/gl2ext.h
make config ABI=armhf VERSION=r3p0
mkdir /usr/lib/mali
echo "/usr/lib/mali" > /etc/ld.so.conf.d/1-mali.conf
make -C include install
make -C lib/mali prefix=/usr libdir='$(prefix)/lib/mali/' install
cd ..
```
compile fbturbo:
```
cd xf86-video-fbturbo
autoreconf -i
./configure --prefix=/usr
make
make install
cd ..
```
compile glshim:
```
cd glshim
cmake .
make
cp lib/libGL.so.1 /usr/lib/
cd ..
```
Assign permissions group video for /dev/ump and /dev/mali
```
echo "KERNEL=="mali", MODE="0660", GROUP="video"" >> /etc/udev/rules.d/50-mali.rules
echo "KERNEL=="ump", MODE="0660", GROUP="video"" >> /etc/udev/rules.d/50-mali.rules
```
add swap if you work with 512MB of RAM:
```
dd if=/dev/zero of=/swapmem bs=1024 count=524288
chown root:root /swapmem
chmod 0600 /swapmem
mkswap /swapmem
swapon /swapmem
```
Add the swap information to /etc/fstab:
```
echo "/swapmem none swap sw 0 0" >> /etc/fstab
reboot
```
END DELETE
# Graphical server


# Plex media center
# Install plex

# Kodi standalone server
Install the main package
```
apt install kodi
```
Create kodi user with blank password
```
addgroup kodi
useradd -c 'kodi user' -u 420 -g kodi -G audio,video,netdev -d /var/lib/kodi -s /usr/bin/nologin kodi
passwd -l kodi > /dev/null
mkdir -p /var/lib/kodi/.kodi 
chown -R kodi:kodi /var/lib/kodi/.kodi
```  
Start kodi-standalone with
```
systemctl start kodi
```
## Change hostname
Change hostname in `/etc/hostname`:
```
echo kiska > /etc/hostname
```
Add `kiska` to `/etc/hosts`:


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



## Plex server
### Install plex
Add the repositories and key:
```
wget -O - https://dev2day.de/pms/dev2day-pms.gpg.key | sudo apt-key add -
echo "deb https://dev2day.de/pms/ jessie main" | sudo tee /etc/apt/sources.list.d/pms.list
apt-get update
```
Install plex and start the service as plex user
```
apt-get install plexmediaserver-installer
service plexmediaserver restart
```

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
