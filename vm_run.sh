#!/bin/bash

set -e

IMAGE=debian.qcow2
QEMU=qemu-system-x86_64

which $QEMU || echo "Could not find $QEMU - try apt install qemu-kvm"

$QEMU \
	-cpu host,vmx=on,intel-pt=on \
	-enable-kvm \
	-hda $IMAGE \
	-smp 4 -m 4G \
	-nographic \
	-monitor telnet:127.0.0.1:5555,server,nowait \
	-serial stdio \
	-device virtio-net-pci,netdev=net1 -netdev user,id=net1,hostfwd=tcp::2022-:22
