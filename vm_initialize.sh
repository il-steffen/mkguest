#!/bin/bash

systemctl enable serial-getty@ttyS0.service
systemctl enable systemd-networkd.service

echo kafl > /etc/hostname

cat > /etc/systemd/network/wired.network << HERE
[Match]
Name=ens3

[Network]
DHCP=yes
HERE

cat > /etc/default/grub << HERE
GRUB_TIMEOUT=2
GRUB_DISABLE_OS_PROBER=true
GRUB_CMDLINE_LINUX_DEFAULT="root=/dev/sda1 mitigations=off console=ttyS0"
GRUB_TERMINAL="console serial"
#GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"
HERE

cat > /etc/apt/sources.list << HERE
deb http://us.archive.ubuntu.com/ubuntu focal main restricted universe multiverse
deb http://us.archive.ubuntu.com/ubuntu focal-updates main restricted universe multiverse
deb http://us.archive.ubuntu.com/ubuntu focal-security main restricted universe multiverse
deb http://us.archive.ubuntu.com/ubuntu focal-backports main restricted universe multiverse
HERE

export DEBIAN_FRONTEND=noninteractive
export LANG="C.UTF-8"

apt-get update
apt-get upgrade -y

apt-get install -y linux-image-kvm grub-pc

apt-get clean
apt-get autoclean
rm -rf /var/lib/apt/lists/*

grub-install --target=i386-pc --recheck /dev/nbd0
update-grub2

# optionally set a root pass
# passwd root

# add a user
useradd -m -U -G kvm,sudo -s /bin/bash joe
echo joe:user |chpasswd
echo root:root |chpasswd

exit # chroot end
