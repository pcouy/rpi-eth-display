#!/bin/bash

MACADDR=$(ifconfig | grep eth0 -A5 | grep ether | awk '{ print $2 }')
MACPREFIX=$(echo $MACADDR | sed -e 's/\([0-9a-f][0-9a-f]:\?[0-9a-f][0-9a-f]:\?[0-9a-f][0-9a-f]:\?\)[0-9a-f][0-9a-f]:\?[0-9a-f][0-9a-f]:\?[0-9a-f][0-9a-f]:\?/\1/')
RPIPREFIXES=(28:cd:c1: b8:27:eb: d8:3a:dd dc:a6:32: e4:5f:01:)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DESTDIR=fakeroot

copy_conf () {
    if [ $# -lt 1 ]; then
        echo "Must specify a file to copy"
        return -1
    fi

   rsync --mkpath -a "$SCRIPT_DIR/../fs/$1" "$DESTDIR/$1"
   chown root:root "$DESTDIR/$1"
   chmod 644 "$DESTDIR/$1"
}

if [[ ! " ${RPIPREFIXES[*]} " =~ " ${MACPREFIX} " ]]; then
    echo "This script must be run from the Raspberry Pi"
    exit
fi

if [ $(id -u) -gt 0 ]; then
    echo "This script must be run as root"
    exit
fi

apt-get install udhcpd

# Configure udhcpd
copy_conf etc/udhcpd.conf
sed -i -e "s/\[PI MAC ADDRESS\]/$MACADDR/" "$DESTDIR/etc/udhcpd.conf"
systemctl enable udhcpd
system restart udhcpd


