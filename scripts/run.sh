#!/bin/sh

set -e
set -x

rm -rf /tmp/qemu-dir
mkdir -p /tmp/qemu-dir/efi/boot
cp build/*.efi /tmp/qemu-dir/efi/boot/bootx64.efi

qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd \
                   -m 1G \
                   -nographic \
                   -serial stdio \
                   -monitor none \
                   -nodefaults \
                   -drive file=fat:rw:/tmp/qemu-dir,format=raw
