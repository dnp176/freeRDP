#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting Advanced RDP Setup...${NC}"

# Update and upgrade
sudo apt-get update
sudo apt-get upgrade -y

# Install necessary packages
sudo apt-get install -y \
    ubuntu-desktop \
    xrdp \
    xorgxrdp \
    xorg \
    dbus-x11 \
    x11-xserver-utils \
    firefox \
    gnome-terminal \
    file-manager \
    nautilus

# Stop and disable lightdm (if exists)
sudo systemctl stop lightdm 2>/dev/null || true
sudo systemctl disable lightdm 2>/dev/null || true

# Configure XRDP
sudo systemctl enable xrdp
sudo systemctl start xrdp

# Create XRDP configuration
sudo tee /etc/xrdp/xrdp.ini > /dev/null <<EOF
[globals]
bitmap_cache=yes
bitmap_compression=yes
port=3389
crypt_level=low
channel_code=1
max_bpp=24

[xrdp1]
name=sesman-Xvnc
lib=libvnc.so
username=ask
password=ask
ip=127.0.0.1
port=-1
EOF

# Fix session management
sudo tee /etc/xrdp/startwm.sh > /dev/null <<'EOF'
#!/bin/sh
if [ -r /etc/default/locale ]; then
  . /etc/default/locale
  export LANG LANGUAGE
fi

export XDG_SESSION_TYPE=x11
export GNOME_SHELL_SESSION_MODE=ubuntu
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
export XDG_CONFIG_DIRS=/etc/xdg/xdg-ubuntu:/etc/xdg

# Start GNOME
export XDG_SESSION_DESKTOP=ubuntu
export XDG_DATA_DIRS=/usr/share/ubuntu:/usr/local/share:/usr/share:/var/lib/snapd/desktop
export XDG_CONFIG_DIRS=/etc/xdg/xdg-ubuntu:/etc/xdg

exec /usr/bin/gnome-session
EOF

sudo chmod +x /etc/xrdp/startwm.sh

# Create user with proper permissions
sudo useradd -m -s /bin/bash -G sudo ubuntuuser 2>/dev/null || true
echo "ubuntuuser:Password123!" | sudo chpasswd

# Configure PolKit for authentication
sudo tee /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla > /dev/null <<EOF
[Allow Colord for All Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF

# Fix DBUS issues
sudo systemctl enable dbus
sudo systemctl start dbus

# Restart XRDP
sudo systemctl restart xrdp

# Allow RDP port
sudo ufw allow 3389

echo -e "${GREEN}RDP Setup Completed!${NC}"
echo -e "${YELLOW}Connection Details:${NC}"
echo -e "${GREEN}Username: ubuntuuser${NC}"
echo -e "${GREEN}Password: Password123!${NC}"
echo -e "${GREEN}Port: 3389${NC}"
