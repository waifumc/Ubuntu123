#!/bin/bash
echo "Code By SNIPA VN"
# Tải package bổ sung vào để tải:)))
apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-utils \
    sudo \
    cloud-image-utils \
    software-properties-common \
    genisoimage \
    novnc \
    websockify \
    curl \
    unzip \
    python3-pip \
    openssh-client \
    net-tools \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/* && apt clean

# Tạo thư mục bên trong noVNC
mkdir -p /data /novnc /opt/qemu /cloud-init

# Tải ubuntu 22.04 image
curl -L https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \
-o /opt/qemu/ubuntu.img

# Viết host
echo "instance-id: servertipacvn\nlocal-hostname: servertipacvn" > /cloud-init/meta-data

# Chỉnh sửa config image ubuntu
RUN printf "#cloud-config\n\
preserve_hostname: false\n\
hostname: servertipacvn\n\
users:\n\
  - name: root\n\
    gecos: root\n\
    shell: /bin/bash\n\
    lock_passwd: false\n\
    passwd: \$6\$abcd1234\$W6wzBuvyE.D1mBGAgQw2uvUO/honRrnAGjFhMXSk0LUbZosYtoHy1tUtYhKlALqIldOGPrYnhSrOfAknpm91i0\n\
    sudo: ALL=(ALL) NOPASSWD:ALL\n\
disable_root: false\n\
ssh_pwauth: true\n\
chpasswd:\n\
  list: |\n\
    root:root\n\
  expire: false\n\
runcmd:\n\
  - systemctl enable ssh\n\
  - systemctl restart ssh\n" > /cloud-init/user-data

# Tạo Cloud-Iso cho image ubuntu 22.04
genisoimage -output /opt/qemu/seed.iso -volid cidata -joliet -rock \
/cloud-init/user-data /cloud-init/meta-data

# Setup noVNC
curl -L https://github.com/novnc/noVNC/archive/refs/tags/v1.3.0.zip -o /tmp/novnc.zip && \
unzip /tmp/novnc.zip -d /tmp && \
mv /tmp/noVNC-1.3.0/* /novnc && \
rm -rf /tmp/novnc.zip /tmp/noVNC-1.3.0
# Tải file start.sh để bắt đầu khởi chạy
wget -O start.sh https://github.com/Snhvn/Ubuntu123/raw/refs/heads/main/start.sh
#
clear
echo "Đang chạy vui lòng đừng tắt"
chmod +x start.sh && \
bash start.sh
