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

    if [ $# -lt 2 ]; then
        UMASK=644
    else
        UMASK=$2
    fi

   rsync --mkpath -a "$SCRIPT_DIR/../fs/$1" "$DESTDIR/$1"
   chown root:root "$DESTDIR/$1"
   chmod $UMASK "$DESTDIR/$1"
}

if [[ ! " ${RPIPREFIXES[*]} " =~ " ${MACPREFIX} " ]]; then
    echo "This script must be run from the Raspberry Pi"
    exit
fi

if [ $(id -u) -gt 0 ]; then
    echo "This script must be run as root"
    exit
fi

apt-get install udhcpd \
    ffmpeg supervisor \
    tcpdump

# Configure udhcpd
copy_conf etc/udhcpd.conf
sed -i -e "s/\[PI MAC ADDRESS\]/$MACADDR/" "$DESTDIR/etc/udhcpd.conf"
systemctl enable udhcpd
systemctl restart udhcpd

# Change VideoCore driver to allow turning the screen off
copy_conf boot/config.txt 755
# Script that determines if screen should be on or off
copy_conf root/check_screen_input.sh 755

# Configure supervisor
copy_conf etc/supervisor/conf.d/pimonitor.conf
systemctl enable supervisor
systemctl restart supervisor

# Ask to reboot
echo 'Reboot (necessary for power management) ? (y/n)' && read x && [[ "$x" == "y" ]] && /sbin/reboot
