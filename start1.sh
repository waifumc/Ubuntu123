#!/bin/bash
set -e

echo "Nhập số Gb ram của bạn (ví dụ: nếu muốn có 8gb ram thì nhập số 8 thôi"
read ram1
DISK="/data/vm.raw"
IMG="/opt/qemu/ubuntu.img"
SEED="/opt/qemu/seed.iso"
RAM="$ram1"
if [ ! -f "$DISK" ]; then
 echo "Creating VM disk..."
 qemu-img convert -f qcow2 -O raw "$IMG" "$DISK"
 qemu-img resize "$DISK" 30G
fi
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

echo "Muốn vào được web noVNC thì mở tab mới (Ctrl + B +C) nhập lệnh là "cloudflared tunnel --url http://localhost:6080"

# Wait for SSH port to be ready
for i in {1..30}; do
  nc -z localhost 2222 && echo "✅ VM is ready!" && break
  echo "⏳ Waiting for SSH..."
  sleep 2
done

wait
