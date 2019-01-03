# Home Assistant

## Installation
### Create a new user hass:
```
useradd -m -g users -G audio,lp,dialout,gpio -s /bin/zsh hass
passwd homeassistant << EOF
$PASSWORD
$PASSWORD
```

### Install
Setup python with `pip`:
```
sudo apt install -y python3 python3-dev python3-pip python3-venv build-essential libssl-dev libffi-dev python-dev libffi-dev -y
```

Install home assistant in a virtual environment:
```
cd /opt
python3 -m venv homeassistant
cd homeassistant
source bin/activate
python3 -m pip install wheel
python3 -m pip install homeassistant
```
Change ownership to `hass:users` to allow update


### Automatic start
Create service files `/etc/systemd/system/home-assistant@.service`
```
[Unit]
Description=Home Assistant
After=network-online.target

[Service]
Type=simple
User=%i
ExecStart=/opt/homeassistant/bin/hass -c "/home/hass/.homeassistant"

[Install]
WantedBy=multi-user.target
```
Then start and enable
```
systemctl daemon-reload
systemctl start home-assistant@hass
systemctl enable home-assistant@hass

```
Check in webserver at http://IP:8123

## Configuration
### MQTT broker
Install and activate MQTT broker
```
apt install -y mosquitto
```
Check the service status with
```
service mosquitto status
```
Modifiy the home-assistant service with adding:
`
...
[Unit]
After=network.target mosquitto.service
...
```



# sources:
https://www.home-assistant.io/docs/installation/armbian/
