# Network UPS Tools server

![Docker Image Size](https://img.shields.io/docker/image-size/J-u-n-o/nut-upsd)

Docker image for Network UPS Tools server published on [Docker Hub](https://hub.docker.com/r/J-u-n-o/nut-upsd), source on [GitHub](https://github.com/J-u-n-o/nut-upsd) forked from [Docker Hub](https://hub.docker.com/r/aimandebug/nut-upsd), source on [GitHub](https://github.com/aimandebug/nut-upsd).
Using work from https://github.com/monstermuffin/nut-docker/ and  the great work of [Gianpaolo Del Matto](https://github.com/gpdm).

Thank you.


## Usage

See for configuration:

[GitHub monstermuffin/nut-docker](https://github.com/monstermuffin/nut-docker/).


## Truenas

Setup USB device (UGreen US3000, but applies to other USB devices as well) using system advanced sysctl config item:

type: udev, name: 99-us3000ups
value:
ATTR{idVendor}=="2b89", ATTR{idProduct}=="ffff", MODE="0664", OWNER="nut_on_host", GROUP="nut_on_host", SYMLINK+="us3000ups"

    
This image provides a complete UPS monitoring service (USB driver tested only).

Using nut config files as present on the host, accessed using a mounted volume.
Container starts using root to allow changing user/group ids in the container

Start the container:
nut_on_host user id: 1234
NUT_USER user as defined in the docker image, can be 'nut' or 'root'


```sh
docker run \
  -d \
  --name nut-upsd \
  --network docker_macvlan \
  --ip 192.168.2.123 \
  --mac-address 12:34:56:78:90:ab \
  --env NUT_UID=1234  --env NUT_GID=1234  --env NUT_USER=nut \
  -p 3493:3493 \
  -v /mnt/host/nut:/etc/nut:ro \
  -v /dev/bus/usb:/dev/bus/usb \
  --device-cgroup-rule='c 189:* rmw' \
  ghcr.io/j-u-n-o/nut-upsd:2.8.5
```

## Misc
Possible to use to start the app using a different UID:
```
 	su-exec
```
Hints about updating firmware
```
  https://github.com/networkupstools/nut/issues/2987
 ./us3000_tb_ota` US3000_TB_V3.3.bin
  filename: TP-0004-DCM00001
```
