# ArchRouter
Router/Access Point installation on a Raspeberry Pi

- hostpadd
- blynk server
- monitorix
- 

Read-only root/boot
Write-access to home/tmp/var

## 0. ArchLinux Installation on SD Card
Source: https://archlinuxarm.org/platforms/armv6/raspberry-pi
Replace mmcblkX in the following instructions with the device name for the SD card as it appears on your computer.

### 0.1 Create filesystem
Start fdisk to partition the SD card:
```
    fdisk /dev/mmcblkp0
```
At the fdisk prompt, delete old partitions and create a new one:
1. Type o. This will clear out any partitions on the drive.
2. Type p to list partitions. There should be no partitions left.
3. Type n, then p for primary, 1 for the first partition on the drive, press ENTER to accept the default first sector, then type +100M for the last sector.
4. Type t, then c to set the first partition to type W95 FAT32 (LBA).
5. Type n, then p for primary, 2 for the second partition on the drive, press ENTER to accept the default first sector, then type +4G for the last sector.
6. Type n, then p for primary, 3 for the second partition on the drive, press ENTER to accept the default first sector, then type +4G for the last sector.
7. Type n, then p for primary, 4 for the second partition on the drive, and then press ENTER twice to accept the default first and last sector.
8. Write the partition table and exit by typing w.

Create and mount the FAT filesystem:
```
    mkfs.vfat /dev/mmcblkpXs1
    mkdir boot
    mount /dev/sdX1 boot
```

Create and mount the ext4 filesystem:
```
    mkfs.ext4 /dev/mmcblkpXs2
    mkdir root
    mount /dev/sdX2 root
```
Create home anda data
```
    mkfs.ext4 /dev/mmcblkpXs3
    mkfs.ext4 /dev/mmcblkpXs4
```

### 0.2 Install ArchLinux system
Download and extract the root filesystem (as root, not via sudo):
```
    wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
    bsdtar -xpf ArchLinuxARM-rpi-latest.tar.gz -C root
    sync
```
Move boot files to the first partition:
```
    mv root/boot/* boot
```
Unmount the two partitions:
```
    umount boot root
```

### 0.3 Boot and login
Insert the SD card into the Raspberry Pi, connect ethernet, and apply 5V power.

Login as the default user alarm with the password alarm.

The default root password is root.

## 1. Configuration
