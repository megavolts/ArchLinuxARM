#!/bin/bash
echo -e ". Installing I2C RTC for Arch Linux ARM"
echo -e ""

pacman -S --needed --noconfirm i2c-tools
echo -e ".. activating I2C devicetree in /boot/config.txt"
echo 'device_tree_param=i2c_arm=on' >> /etc/config.txt

#-----------------------------------------------------------
echo -e ""
echo -e ".. adding i2c and rtc modules to the conf"
echo "rtc-ds1307" >> /etc/modules-load.d/rtc.conf
echo "i2c-dev"    >> /etc/modules-load.d/rtc.conf
sort -u /etc/modules-load.d/rtc.conf -o /etc/modules-load.d/rtc.conf 

#-----------------------------------------------------------
echo -e ""
echo -e ".. creating init script for the RTC"

mkdir -p /usr/lib/systemd/scripts/
cat > /usr/lib/systemd/scripts/rtc << ENDRTCSCRIPT
#!/bin/bash
# create an i2c device DS1307 (works also for DS3231)
# set systemclock from external i2c-rtc
echo 'ds1307 0x68' > /sys/class/i2c-adapter/i2c-1/new_device
hwclock -s
ENDRTCSCRIPT

chmod 755 /usr/lib/systemd/scripts/rtc

echo -e ""
echo -e ".. creating service for the RTC"

cat > /etc/systemd/system/rtc.service << ENDRTCSERVICE
[Unit]
Description=RTClock
Before=network.target
 
[Service]
ExecStart=/usr/lib/systemd/scripts/rtc
Type=oneshot
[Install]
WantedBy=multi-user.target
ENDRTCSERVICE
ca/usr 
#-----------------------------------------------------------
echo -e ""
echo -e ".. enabling and starting RTC service"

systemctl enable rtc
systemctl start rtc
