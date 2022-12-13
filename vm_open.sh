#!/bin/bash

set -e

MNT=$(mktemp -d)
sudo modprobe nbd
sudo qemu-nbd -c /dev/nbd0 debian.qcow2

sudo mount /dev/nbd0p1 $MNT
sudo mount --bind /dev  $MNT/dev
sudo mount --bind /sys  $MNT/sys
sudo mount --bind /proc $MNT/proc

echo "/dev/nbd0 mounted at $MNT"
sudo chroot $MNT /bin/bash

sudo umount $MNT/dev
sudo umount $MNT/sys
sudo umount $MNT/proc
sudo umount $MNT
sudo qemu-nbd -d /dev/nbd0
