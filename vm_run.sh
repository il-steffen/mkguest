#!/bin/bash

IMAGE=debian.qcow2

qemu-system-x86_64 \
	-cpu host,vmx=on,intel-pt=on \
	-enable-kvm \
	-hda $IMAGE \
	-smp 4 -m 4G \
	-nographic \
	-monitor telnet:127.0.0.1:5555,server,nowait \
	-serial stdio \
	-device virtio-net-pci,netdev=net1 -netdev user,id=net1,hostfwd=tcp::2022-:22
