#!/bin/bash 

mkdir build/

version=20.04
serverqcow2=packer-ubuntu-${version}-live-server.qcow2
iso=ubuntu-${version}-live-server-amd64.iso

# 1. download ISO 
echo "::prepare name=ISO::Downloading" 
curl -L -o build/${iso} https://releases.ubuntu.com/${version}/${iso}

# 2. extract kernel 

# 3. create a disk 

echo "::prepare name=QCOW::Created" 
qemu-img create -f qcow2 ./build/${serverqcow2} 5G

# 4. spin up a config server
echo "::prepare name=cloud-init::webserverrunning" 
python3 -m http.server 3003 --directory subiquity/http &
WEBPID=$!

echo "::build name=qemu::building" 
# 5. boot the installer
qemu-system-x86_64 \
    -boot d \
    -no-reboot \
    -vga virtio \
    -drive file=build/${iso},media=cdrom \
    -machine type=pc,accel=tcg \
    -m 2048M \
    -nographic \
    -display none \
    -drive file=./build/${serverqcow2},if=virtio,cache=writeback,discard=ignore,format=qcow2 \
    -netdev user,id=user.0,hostfwd=tcp::7722-:22 \
    -device virtio-net,netdev=user.0 \
    -kernel ./vmlinuz \
    -initrd ./initrd \
    -append 'autoinstall ds=nocloud-net;s=http://_gateway:3003/ console=ttyS0'

echo "::build name=qemu::finished" 

# 4. md5sum the final

ls -al build/

# md5sum ./build/${serverqcow2}
kill ${WEBPID}
