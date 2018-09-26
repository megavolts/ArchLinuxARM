#!/bin/sh -exu
dev=$1
cd $(mktemp -d)

function umountboot {
    umount boot || true
    umount root || true
}

# RPi1/Zero (armv6h):
archlinux=/tmp/ArchLinuxARM-rpi-latest.tar.gz
url=http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz

# RPi2 (armv7h):
# archlinux=/tmp/ArchLinuxARM-rpi-2-latest.tar.gz
# url=http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz

curl -L -o $archlinux -z $archlinux $url
parted -s $dev mklabel msdos
parted -s $dev mkpart primary fat32 1 128
parted -s $dev mkpart primary ext4 128 -- -1
mkfs.vfat ${dev}p1
mkfs.ext4 -F ${dev}p2
mkdir -p boot
mount ${dev}p1 boot
trap umountboot EXIT
mkdir -p root
mount ${dev}p2 root

bsdtar -xpf $archlinux -C root
sync
mv root/boot/* boot

# Commands to configure WiFi before first boot (netctl-auto)
# - you need to temp edit root/etc/pacman.d to point to /path/to/root/etc/pacman.d/mirrorlist
cp root/etc/pacman.conf pacman.armv6h.conf 
sed -i 's!#RootDir     = /!RootDir=root!' pacman.armv6h.conf 
sed -i 's!#DBPath      = /var/lib/pacman/!DBPath=root/var/lib/pacman/!' pacman.armv6h.conf 
sed -i 's!#CacheDir    = /var/cache/pacman/pkg/!CacheDir=root/var/cache/pacman/pkg/!' pacman.armv6h.conf 
sed -i 's!#LogFile     = /var/log/pacman.log!LogFile=root/var/log/pacman.log!' pacman.armv6h.conf 
sed -i 's!#GPGDir      = /etc/pacman.d/gnupg/!GPGDir=root/etc/pacman.d/gnupg/!' pacman.armv6h.conf 
sed -i 's!#HookDir     = /etc/pacman.d/hooks/!HookDir=root/etc/pacman.d/hooks/!' pacman.armv6h.conf 
sed -i 's!Include = /etc/pacman.d/mirrorlist!Include = root/etc/pacman.d/mirrorlist!' pacman.armv6h.conf 
pacman --config pacman.armv6h.conf  -Sy
pacman --config pacman.armv6h.conf  -S wpa_actiond
rm pacman.armv6h.conf

# - change it back after installing
ln -sf /usr/lib/systemd/system/netctl-auto@.service root/etc/systemd/system/netctl-auto@wlan0.service
cat >root/etc/netctl/wlan0-SSID <<EOF
Description='WiFi - SSID'
Interface=wlan0
Connection=wireless
Security=none
ESSID=AdakIsland
IP=dhcp
EOF
echo -e "Rasberry Pi Zero Installed with preconfigured wifi"
