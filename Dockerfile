FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
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

# Create required directories
RUN mkdir -p /data /novnc /opt/qemu /cloud-init

# Download Ubuntu 22.04 cloud image
RUN curl -L https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \
    -o /opt/qemu/ubuntu.img

# Write meta-data
RUN echo "instance-id: servertipacvn\nlocal-hostname: servertipacvn" > /cloud-init/meta-data

# Write user-data with working root login and password 'root'
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

# Create cloud-init ISO
RUN genisoimage -output /opt/qemu/seed.iso -volid cidata -joliet -rock \
    /cloud-init/user-data /cloud-init/meta-data

# Setup noVNC
RUN curl -L https://github.com/novnc/noVNC/archive/refs/tags/v1.3.0.zip -o /tmp/novnc.zip && \
    unzip /tmp/novnc.zip -d /tmp && \
    mv /tmp/noVNC-1.3.0/* /novnc && \
    rm -rf /tmp/novnc.zip /tmp/noVNC-1.3.0

# Start script
RUN echo "Creating VM disk..." && \
    qemu-img convert -f qcow2 -O raw /opt/qemu/ubuntu.img /data/vm.raw && \
    qemu-img resize /data/vm.raw 128G

# Start VM
# Start noVNC


# Wait for SSH port to be ready

RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list && sudo apt update && sudo apt install ngrok && \
    ngrok config add-authtoken 2x2On2r9mfo5WTrl6OQJiMvi3xY_7SfeNm4NS24qEwKErpMB6
    
RUN mkdir -p /app && echo "NoVNC Session Running..." > /app/index.html
WORKDIR /app

EXPOSE 6080

# RUN cat <<'EOF' > /start.sh
# !/bin/bash
   # python3 -m http.server 6080 & \
   # ngrok http 6080 
   RUN qemu-system-x86_64 \
    -m 16500 \
    -drive file=/data/vm.raw,format=raw,if=virtio \
    -drive file=/opt/qemu/seed.iso,format=raw,if=virtio \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -device virtio-net,netdev=net0 \
    -vga virtio \
    -display vnc=:0
    
# EOF

# RUN chmod +x /start.sh

VOLUME /data

CMD python3 -m http.server 6080 & \
    ngrok http 6080
