#!/bin/bash

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install XFCE and RDP
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xorg \
    dbus-x11 \
    x11-xserver-utils \
    firefox \
    vim \
    git \
    curl \
    wget

# Install XRDP
sudo apt-get install -y xrdp
sudo systemctl enable xrdp
sudo systemctl start xrdp

# Configure XRDP
echo "xfce4-session" > ~/.xsession
sudo systemctl restart xrdp

# Configure firewall
sudo ufw allow 3389

# Create user
sudo useradd -m -s /bin/bash ubuntuuser
echo "ubuntuuser:Password123" | sudo chpasswd
sudo usermod -aG sudo ubuntuuser

# Fix session issues
sudo sed -i 's/^use_vsock=.*/use_vsock=false/' /etc/xrdp/xrdp.ini
sudo sed -i 's/^port=3389/port=tcp:\/\/:3389/' /etc/xrdp/xrdp.ini

# Restart services
sudo systemctl restart xrdp
sudo systemctl restart dbus

echo "RDP setup completed successfully!"
echo "Username: ubuntuuser"
echo "Password: Password123"
