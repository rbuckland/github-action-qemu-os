#!/bin/bash 

mkdir build/

serverqcow2=packer-ubuntu-21.04-live-server.qcow2
version=21.04
iso=ubuntu-${version}-live-server-amd64.iso
# 1. download ISO 

curl -L -o build/${iso} https://releases.ubuntu.com/${version}/${iso}

# 2. extract kernel 

# 3. create a disk 

qemu-img create -f qcow2 ./build/${serverqcow2} 5G

# 4. spin up a config server
python3 -m http.server 3003 --directory subiquity/http
WEBPID=$!

# 5. boot the installer
qemu-system-x86_64 \
    -boot d \
    -no-reboot \
    -vga virtio \
    -drive file=build/${iso},media=cdrom \
    -machine type=pc,accel=tcg \
    -m 2048M \
    -nographic \
    -display curses,show-cursor=on \
    -drive file=./build/${serverqcow2},if=virtio,cache=writeback,discard=ignore,format=qcow2 \
    -netdev user,id=user.0,hostfwd=tcp::7722-:22 \
    -device virtio-net,netdev=user.0 \
    -kernel ./vmlinuz \
    -initrd ./initrd \
    -append 'autoinstall ds=nocloud-net;s=http://_gateway:3003/ console=ttyS0'

# 4. md5sum the final

ls -al build/

# md5sum ./build/${serverqcow2}
kill ${WEBPID}
