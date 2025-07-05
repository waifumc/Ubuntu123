#!/bin/bash
set -e

DISK="/data/vm.raw"
IMG="/opt/qemu/ubuntu.img"
SEED="/opt/qemu/seed.iso"

 
echo "Creating VM disk..."
qemu-img convert -f qcow2 -O raw "$IMG" "$DISK"
qemu-img resize "$DISK" 30G
# Start VM
qemu-system-x86_64 \
    -m "$RAM"G \
    -drive file="$DISK",format=raw,if=virtio \
    -drive file="$SEED",format=raw,if=virtio \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -device virtio-net,netdev=net0 \
    -vga virtio \
    -display vnc=:0 \
    -daemonize

# Start noVNC
websockify --web=/novnc 6080 localhost:5900 &

echo "================================================"
echo " 🖥️  VNC: http://localhost:6080/vnc.html"
echo " 🔐 SSH: ssh root@localhost -p 2222"
echo " 🧾 Login: root / root"
echo " Supported Code Sandbox (use ngrok or cloudflare)"
echo " Code By Snipavn/Snhvn (Github) Youtube: https://youtube.com/@snipavn205 & Youtube: HopingBoyz" 
echo "================================================"

# Wait for SSH port to be ready
for i in {1..30}; do
  nc -z localhost 2222 && echo "✅ VM is ready!" && break
  echo "⏳ Waiting for SSH..."
  sleep 2
done

wait
