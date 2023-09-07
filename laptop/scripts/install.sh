#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DESTDIR=fakeroot
RESTART_REQUIRED=$(false)

if [ $(id -u) -eq 0 ]; then
    echo "You are running this script as root"
    echo "You should run this script as your regular user (the one that will be invoking xrandr)"
    echo "This script uses sudo when it needs admin privileges"
    echo "If you know what you are doing and want to run it as root anyway, edit this script to allow it to continue even when running as root"
    exit
fi
echo "This script contains sudo commands that will probably ask for your password"

# Check if ffmpeg is installed
ffmpeg > /dev/null 2>&1
EXITCODE=$?
if [ $EXITCODE -eq 127 ]; then
    echo "Please install ffmpeg and run this script again"
    exit
fi

# Check that xrandr in installed
XRANDROUTPUT=$(xrandr 2> /dev/null)
EXITCODE=$?
if [ $EXITCODE -eq 127 ]; then
    echo "Please install xrandr and run this script again"
    exit
fi
if [ $EXITCODE -eq 1 ]; then
    echo "Please run this script from an X session"
    exit
fi

echo $XRANDROUTPUT | grep VIRTUAL1 > /dev/null
VIRTUAL1_CONFIGURED=$?
if [ $VIRTUAL1_CONFIGURED -eq 0 ]; then
    # Configure modeline
    echo "Screen width (in natural rotation, you'll be able to rotate it later in xrandr) : "
    read WIDTH
    echo "Screen height : "
    read HEIGHT
    echo "Screen FPS : "
    read FPS
    MODELINE=$(gtf $WIDTH $HEIGHT $FPS | grep "Modeline" | awk '{ $1="" }1')
    MODE=$(echo $MODELINE | awk '{ gsub(/"/, "");print $1 }')
    xargs xrandr --newmode <<< "$MODELINE"
    xrandr --addmode VIRTUAL1 $MODE
else
    # Install
    echo "Configuring VIRTUAL1 output"
    sudo rsync -a --mkpath "$SCRIPT_DIR/../fs/usr/share/X11/xorg.conf.d/20-intel.conf" "$DESTDIR/usr/share/X11/xorg.conf.d/20-intel.conf"
    sudo chown root:root "$DESTDIR/usr/share/X11/xorg.conf.d/20-intel.conf"
    sudo chmod 644 "$DESTDIR/usr/share/X11/xorg.conf.d/20-intel.conf"
    RESTART_REQUIRED=$(true)
fi

if [ ! -f "$DESTDIR/$HOME/.local/bin/xrandr" ]; then
    # Install xrandr wrapper
    echo "Installing xrandr wrapper"
    rsync --mkpath "$SCRIPT_DIR/../fs/\$HOME/.local/bin/xrandr" "$DESTDIR/$HOME/.local/bin/xrandr"
    chmod +x "$DESTDIR/$HOME/.local/bin/xrandr"
fi

# Check and add ~/.local/bin to $PATH
echo $PATH | grep "$HOME/\.local/bin" > /dev/null
if [ $? -eq 1 ]; then
    echo "Adding \$HOME/.local/bin to \$PATH"
    echo "You will need to log out and back in for it to work"
    echo "In the meantime, you can do the following :"
    echo '    ~/.local/bin/xrandr [XRANDR ARGS]'
    echo 'or  PATH="$HOME/.local/bin:$PATH" arandr'
    echo 'export PATH=$HOME/.local/bin:$PATH' >> "$DESTDIR/$HOME/.profile"
fi

if [ $RESTART_REQUIRED -eq $(true) ]; then
    echo 'Reboot now ? (necessary for VIRTUAL1 display to show up) ? (y/n)' && read x && [[ "$x" == "y" ]] && /sbin/reboot
fi
