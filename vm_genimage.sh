#!/bin/bash

set -e

IMAGE=debian.qcow2
release=focal
utils=less,vim,tmux,git,make
pkgs=locales-all,sudo,net-tools,openssh-server,$utils
# set this to override host default
#mirror=http://us.archive.ubuntu.com/ubuntu

which qemu-img || echo "Could not find qemu-img - try apt install qemu-utils"
which debootstrap || echo "Could not find qemu-img - try apt install debootstrap"

#LANG="C.UTF-8" 
qemu-img create -f qcow2 $IMAGE 8G

sudo modprobe nbd
sudo qemu-nbd -c /dev/nbd0 $IMAGE

sudo parted -s -a optimal -- /dev/nbd0 \
	mklabel msdos \
	mkpart primary ext4 1MiB -0 \
	set 1 boot on

MNT=$(mktemp -d)
sudo mkfs -t ext4 -L root /dev/nbd0p1
sudo mount /dev/nbd0p1 $MNT

cache="$PWD/debootstrap.cache"
mkdir -p $cache
sudo -E debootstrap --cache-dir=$cache --include=$pkgs $release $MNT $mirror

root_uuid="$(sudo blkid | grep '^/dev/nbd0' | grep ' LABEL="root" ' | grep -o ' UUID="[^"]\+"' | sed -e 's/^ //' )"

sudo tee $MNT/etc/fstab << HERE
$root_uuid / ext4 errors=remount-ro 0 1
HERE

proxy_file=$(ls /etc/profile.d/*proxy.sh)
test -f $proxy_file && sudo cp $proxy_file $MNT/$proxy_file

sudo umount $MNT
sudo qemu-nbd -d /dev/nbd0
rmdir $MNT

# chroot to disk
MNT=$(mktemp -d)
sudo qemu-nbd -c /dev/nbd0 $IMAGE
sudo mount $root_uuid $MNT
sudo mount --bind /dev  $MNT/dev
sudo mount --bind /sys  $MNT/sys
sudo mount --bind /proc $MNT/proc
sudo cp vm_initialize.sh $MNT/
sudo chroot $MNT /vm_initialize.sh

# exit
sudo umount $MNT/dev
sudo umount $MNT/sys
sudo umount $MNT/proc
sudo umount $MNT

sudo qemu-nbd -d /dev/nbd0
rmdir $MNT
