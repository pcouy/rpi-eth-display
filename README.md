# Warning : Work In Progress

The installation scripts have not been properly tested yet. You should not run them (especially the laptop one) without reviewing them first.

# Using a Raspberry Pi to add a second HDMI port to a laptop

This repository hosts configuration files from [the technical write-up on my blog](https://pierre-couy.dev/side-projects/2023/03/turning-rpi-into-external-monitor-driver.html).

Additionally, I tried to write install scripts for both the laptop and the Raspberry Pi. This should be the quickest way to get everything up and running. After installing all dependencies and configuration files, you should be able to get a low-latency stream with good quality from your main computer to the Raspberry Pi.

## Getting started

Here are the steps you should take to install everything.

### Raspberry Pi

Flash an SD card with a Raspberry Pi OS image.

You will need internet access for initial setup (to download the dependencies). I recommend using WiFi because you will need the eth interface available to connect it to the main computer. You can disable WiFi after everything is installed.

Using either a keyboard or SSH, install git using `sudo apt-get install git` and clone the repository : `git clone https://github.com/pcouy/rpi-eth-display.git` 

You can now run the install script using `rpi-eth-display/rpi/scripts/install.sh`

### Main computer

Similarly, clone the repository on the computer you want to stream from, then run the install script : `rpi-eth-display/laptop/scripts/install.sh`. You will need to reboot your computer for the VIRUTAL1 screen to show-up. After rebooting, run the install script once again to configure the modeline for the virtual display. You will need to redo this step after every reboot.

### Using it

If everything was setup correctly, you should be able to start a stream simply by enabling the `VIRTUAL1` display in `xrandr` or any of its GUI. The wrapper will auto-start `ffmpeg` using the right options.

If you disabled WiFi on the Pi, you should still be able to SSH into it using the eth link. The Pi's IP address on this interface is `10.0.0.0`.

## TODO

- Change `$DESTDIR` in both install scripts
- Turn the Pi part in a deb package
- Grab the screen resolution from the Pi to auto-generate the modeline
- Auto generation and setup of ssh keys to log into the Pi
