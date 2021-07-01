# Building OS Images, inside a docker container

This repo examples how to build OS images for various platforms, inside a docker container. 

The docker container is designed to be
- run in a CI/CD pipeline
- run from the command line


# Reference


* https://ubuntu.com/server/docs/install/autoinstall-quickstart-s390x

```
 hdiutil attach -noverify -nomount packer_cache/ffca25fa2718072c7ba900c6a966e53224591dab.iso
 mkdir iso/
 mount -t cd9660 /dev/disk4 x
 ls -al iso/
 cat iso/boot/grub/grub.cfg
 cp   iso/casper/vmlinuz .
 cp   iso/casper/initrd . 
```

```
kvm -no-reboot -name auto-inst-test -nographic -m 2048 \
    -drive file=disk-image.qcow2,format=qcow2,cache=none,if=virtio \
    -cdrom ~/Downloads/ubuntu-20.04-live-server-s390x.iso \
    -kernel ~/iso/boot/kernel.ubuntu \
    -initrd ~/iso/boot/initrd.ubuntu \
    -append 'autoinstall ds=nocloud-net;s=http://_gateway:3003/ console=ttysclp0'
```# github-action-qemu-os
