#!/bin/bash
set -e

# Wait for cloud-init to complete
cloud-init status --wait

# Update package list and upgrade all packages
sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install complete Ubuntu desktop environment
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    qemu-guest-agent \
    cloud-init \
    openssh-server \
    ubuntu-desktop \
    ubuntu-drivers-common \
    networkmanager \
    firefox \
    gnome-software \
    gnome-software-plugin-snap

# Enable required services
sudo systemctl set-default graphical.target
sudo systemctl enable gdm
sudo systemctl enable qemu-guest-agent
sudo systemctl start qemu-guest-agent