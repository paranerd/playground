#!/bin/sh

# This script is used to backup a directory by simply plugging in a USB-Drive

# Prerequisites

# Get the UUID of the drive you want to auto-mount
# $ sudo blkid

# Add that UUID to /etc/fstab
# $ echo "UUID=[uuid_goes_here] /mnt ext4 auto,nofail,sync,users,rw 0 0" | sudo tee --append /etc/fstab

# Get vendor- and product-id of your drive
# $ lsusb

# Install "at" (without using "at" our script would be executed BEFORE mounting (thus blocking it))
# $ sudo apt install at

# Create a udev-rule to tell the system what is supposed to happen
# echo 'ACTION=="add", ENV{DEVTYPE}=="usb_device", SUBSYSTEM=="usb", ATTRS{idVendor}=="[vendor-id]", ATTRS{idProduct}=="[product-id]", RUN+="/usr/bin/at -M -f [path_to_run.sh] now"' | sudo tee /etc/udev/rules.d/100-usb.rules

# Reload udev
# $ sudo udevadm control --reload-rules && udevadm trigger
# $ sudo service udev restart

mountpoint=/mnt
mount_wait=0
mount_wait_max=10

echo "Waiting for drive..." >> /home/pi/export/history.log

# Wait for drive to mount
until grep -qs "${mountpoint} " /proc/mounts || [ "$mount_wait" -ge "$mount_wait_max" ]
do
        mount_wait=$((mount_wait+1))
        sleep 1
done

if grep -qs "${mountpoint} " /proc/mounts; then
        echo "Starting export" >> /home/pi/export/history.log

        # Run export
        rsync -av --progress /home/pi/backup/ ${mountpoint} >> /home/pi/export/history.log

        # Make sure everything has been written
        sync

        # Unmount drive
        umount ${mountpoint}
else
        echo "Mount failed" >> /home/pi/export/history.log
fi
