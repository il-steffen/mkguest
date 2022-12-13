#!/bin/bash

set -e 

MNT=$(mount|grep /dev/nbd0|awk '{print $3}')

if test "A$MNT" == "A"; then
	echo "/dev/nbd0 not mounted.."
	exit
fi

for dir in dev sys proc ""; do
	dir=$(realpath $MNT/$dir)
	if mount |grep -q $dir; then
	   echo "Unmounting $dir"
	   sudo umount $dir
	fi
done

sudo qemu-nbd -d /dev/nbd0
