#!/bin/bash
set -e

DISK="/data/vm.raw"
IMG="/opt/qemu/ubuntu.img"
SEED="/opt/qemu/seed.iso"

 
echo "Creating VM disk..."
qemu-img convert -f qcow2 -O raw "$IMG" "$DISK"
qemu-img resize "$IMG" 128G
# Start VM
qemu-system-x86_64 \
    -m 5G \
    -cpu max \
    -accel tcg,thread=multi \
    -drive file="$DISK",format=raw,if=virtio \
    -drive file="$SEED",format=raw,if=virtio \
    -netdev user,id=net0,hostfwd=tcp::2222-:22,dns=1.1.1.1 \
    -device virtio-net,netdev=net0 \
    -nographic

apt install tmate
tmate
