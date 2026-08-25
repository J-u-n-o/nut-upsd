#!/bin/sh -ex


chgrp -R nut /etc/nut /dev/bus/usb
chmod -R o-rwx /etc/nut

/usr/sbin/upsdrvctl start
/usr/sbin/upsd
exec /usr/sbin/upsmon -D
