# Warning : Work In Progress

The installation scripts have not been properly tested yet. You should not run them (especially the laptop one) without reviewing them first. Files from `fs` directories should work fine, as they directly come from the setup I manually installed and use daily.

If you want to try installation scripts anyway, you must edit them both and change `DESTDIR=fakeroot` to `DESTDIR=/` for the files to be copied on your live system. **Do this at your own risks.**

# Using a Raspberry Pi to add a second HDMI port to a laptop

This repository hosts configuration files from [the technical write-up on my blog](https://pierre-couy.dev/tinkering/2023/03/turning-rpi-into-external-monitor-driver.html).

Additionally, I tried to write install scripts for both the laptop and the Raspberry Pi. This should be the quickest way to get everything up and running. After installing all dependencies and configuration files, you should be able to get a low-latency stream with good quality from your main computer to the Raspberry Pi.

## Getting started

Here are the steps you should take to install everything.

### Raspberry Pi

Flash an SD card with a Raspberry Pi OS image. You can [download the latest versions from the official website](https://www.raspberrypi.com/software/operating-systems/) (I recommend using the "Lite" image as we won't need a graphical environment). You can follow [this tutorial about Raspberry Pi installation and initial configuration](https://www.raspberrypi.com/documentation/computers/getting-started.html) if needed.

Alternatively, the install script and streaming should work on a Pi that's already used for something else, but there may be performance issues.

You will need internet access for initial setup (to download the dependencies). I recommend using WiFi because you will need the eth interface available to connect it to the main computer. You can disable WiFi after everything is installed.

Using either a keyboard or SSH, install git using `sudo apt-get install git` and clone the repository : `git clone https://github.com/pcouy/rpi-eth-display.git` 

You can now run the install script as root using `sudo rpi-eth-display/rpi/scripts/install.sh`. This script takes care of installing all dependencies on the Pi.

### Main computer

#### Requirements

The scripts in this repository only work for a Linux computer using a X server. It should be easy to modify the `ffmpeg` command so it works on Wayland, Windows or MacOS. However, install scripts and wrappers need more work. If you want to work on this, please open an issue so I can link to your work here.

Currently, the configuration included only works with intel CPUs with integrated graphics. From [Virtual Display Linux](https://github.com/dianariyanto/virtual-display-linux), there is an [alternative configuration file for Nvidia GPU](https://github.com/dianariyanto/virtual-display-linux/issues/9#issuecomment-786389065).

If you're using a Linux computer running an X server with Intel integrated graphics, you are good to go. Just make sure the `ffmpeg` command is available and proceed to the next step.

#### Installation

Similarly, clone the repository on the computer you want to stream from, then run the install script (but this time as your regular user) : `rpi-eth-display/laptop/scripts/install.sh`. You will need to reboot your computer for the `VIRUTAL1` screen to show-up. After rebooting, run the install script once again to configure the modeline for the virtual display. You will need to redo this step after every reboot.

### Using it

If everything was setup correctly, you should be able to start a stream simply by enabling the `VIRTUAL1` display in `xrandr` or any of its GUI. The wrapper will auto-start `ffmpeg` using the right options.

If you disabled WiFi on the Pi, you should still be able to SSH into it using the eth link. The Pi's IP address on this interface is `10.0.0.0`.

## TODO

- Properly test install scripts and change `$DESTDIR` in both install scripts
- Turn the Pi part into a deb package
- Auto generation and setup of ssh keys to log into the Pi
- Grab the screen resolution from the Pi to auto-generate the modeline
