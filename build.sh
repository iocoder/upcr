#!/bin/sh

set -e
set -x

rm -rf build
mkdir build

./autogen.sh

cd build

../configure
make
if [ "$TFTP_SERVER" != "" ]
then
  scp image/upcr-21.09.efi "$TFTP_USER@$TFTP_SERVER:$TFTP_DIR/"
fi

rm -rf /tmp/qemu-dir
mkdir -p /tmp/qemu-dir/efi/boot
cp image/*.efi /tmp/qemu-dir/efi/boot/bootx64.efi

qemu-system-x86_64 -enable-kvm \
                   -cpu host \
                   -bios /usr/share/ovmf/OVMF.fd \
                   -smp 8 \
                   -m 1G \
                   -vga std \
                   -serial stdio \
                   -drive file=fat:rw:/tmp/qemu-dir,format=raw
