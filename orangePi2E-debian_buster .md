# Media Center
## Install PlexMediaPlayer
Install dependencies
```
apt install autoconf automake libtool libharfbuzz-dev libfreetype6-dev libfontconfig1-dev libx11-dev libxrandr-dev libvdpau-dev libva-dev mesa-common-dev libegl1-mesa-dev yasm libasound2-dev libpulse-dev libuchardet-dev zlib1g-dev libfribidi-dev git libgl1-mesa-dev libsdl2-dev cmake libgnutls28-dev libgnutls30
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

Add qt5.10.1:
```
apt-get -y update
apt-get -y install build-essential libgl1-mesa-dev libassimp-dev libfontconfig1 libdbus-1-3 wget
wget http://download.qt.io/official_releases/qt/5.10/5.10.1/qt-opensource-linux-x64-5.10.1.run
chmod +x qt-opensource-linux-x64-5.10.1.run
./qt-opensource-linux-x64-5.10.1.run
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
service plexmediaserver start
```apt 

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
