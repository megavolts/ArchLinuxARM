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
### 0.1 Partiton SD
Start fdisk to partition the SD card:
```
  fdisk /dev/sdX
```
At the fdisk prompt, delete old partitions and create a new one:
.a Type o. This will clear out any partitions on the drive.
.b Type p to list partitions. There should be no partitions left.
.c Type n, then p for primary, 1 for the first partition on the drive, press ENTER to accept the default first sector, then type +100M for the last sector.
.d Type t, then c to set the first partition to type W95 FAT32 (LBA).
.e Type n, then p for primary, 2 for the second partition on the drive, press ENTER to accept the default first sector, then type +4G for the last sector.
.f Type n, then p for primary, 3 for the second partition on the drive, press ENTER to accept the default first sector, then type +4G for the last sector.
.g Type n, then p for primary, 4 for the second partition on the drive, and then press ENTER twice to accept the default first and last sector.
.h Write the partition table and exit by typing w.

Create and mount the FAT filesystem:

    mkfs.vfat /dev/sdX1
    mkdir boot
    mount /dev/sdX1 boot

    Create and mount the ext4 filesystem:

    mkfs.ext4 /dev/sdX2
    mkdir root
    mount /dev/sdX2 root

    Download and extract the root filesystem (as root, not via sudo):

    wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
    bsdtar -xpf ArchLinuxARM-rpi-latest.tar.gz -C root
    sync

    Move boot files to the first partition:

    mv root/boot/* boot

    Unmount the two partitions:

    umount boot root

    Insert the SD card into the Raspberry Pi, connect ethernet, and apply 5V power.
    Use the serial console or SSH to the IP address given to the board by your router.
        Login as the default user alarm with the password alarm.
        The default root password is root.
