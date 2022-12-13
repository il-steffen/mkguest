# mkguest

Scripts for quickly creating and running simple Linux VMs for Qemu.

debootstrap is almost good enough, but sometimes we want a full system with bootloader and all.
qemu-nbd is the magic ingredient to batch-create a proper disk, install and customize as needed.
