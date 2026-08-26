# Network UPS Tools server

![Docker Image Size](https://img.shields.io/docker/image-size/J-u-n-o/nut-upsd)

Docker image for Network UPS Tools server published on [Docker Hub](https://hub.docker.com/r/J-u-n-o/nut-upsd), source on [GitHub](https://github.com/J-u-n-o/nut-upsd) forked from [Docker Hub](https://hub.docker.com/r/aimandebug/nut-upsd), source on [GitHub](https://github.com/aimandebug/nut-upsd).
Using work from https://github.com/monstermuffin/nut-docker/ and  the great work of [Gianpaolo Del Matto](https://github.com/gpdm).

Thank you.

see also [GitHub DartSteven/Nutify](https://github.com/DartSteven/Nutify/tree/main)

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

Because the docker host cannot access its dockers using the macvlan, also use the bridge to allow a second network connection using the docker bridge to have a 'second' port accessible (only) by the docker host/Truenas server.

```
$ sudo docker network inspect bridge
[
    {
        "Name": "bridge",
        "IPAM": {
            "Config": [
                {
                    "Subnet": "172.16.0.0/24",
                    "Gateway": "172.16.0.1"
                }
            ]
        },
```
However setting an fixed/desired ip address for the container is not allowed on the internal bridge, so create a custom bridge:
```
sudo docker network create \
  --driver bridge \
  --subnet 172.16.1.0/24 \
  nut-bridge
```
and so 
```
sudo docker network connect --ip 172.16.1.10 nut-bridge nut-upsd
```

```
]$ sudo docker network inspect nut-bridge
[
    {
        "Name": "nut-bridge",
        },
        "ConfigOnly": false,
        "Containers": {
            "xyz": {
                "IPv4Address": "172.16.1.10/24",
                "IPv6Address": "fdd0:0:0:1::2/64"
            }
        },
    }
]
```

from truenas/host
```
$ upsc us3000ups@172.16.1.10:3493
Init SSL without certificate database
battery.charge: 100
battery.charge.low: 20
battery.runtime: 65535
battery.type:
device.mfr: UGREEN
device.model: US3000
device.serial: DC600
device.type: ups
driver.debug: 0
driver.flag.allow_killpower: 0
driver.name: usbhid-ups
driver.parameter.interrupt_pipe_no_events_tolerance: -1
driver.parameter.pollfreq: 30
driver.parameter.pollinterval: 2
driver.parameter.pollonly: enabled
driver.parameter.port: auto
driver.parameter.productid: ffff
driver.parameter.subdriver: Arduino
driver.parameter.synchronous: auto
driver.parameter.vendorid: 2b89
driver.state: quiet
driver.version: 2.8.5
driver.version.data: Arduino HID 0.22
driver.version.internal: 0.71
driver.version.usb: libusb-1.0.30 (API: 0x0100010C)
input.voltage: 20.0
output.voltage: 19.0
ups.delay.shutdown: 20
ups.delay.start: 30
ups.load: 1
ups.mfr: UGREEN
ups.model: US3000
ups.productid: ffff
ups.serial: DC600
ups.status: OL DISCHRG
ups.timer.reboot: 0
ups.timer.shutdown: -1
ups.timer.start: 0
ups.vendorid: 2b89
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
