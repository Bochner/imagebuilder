#!/bin/bash
set -e

# Update all packages
sudo dnf update -y

# Install essential packages and workstation environment
sudo dnf group install -y \
    "Fedora Workstation" \
    "Development Tools" \
    "GNOME Desktop Environment"

sudo dnf install -y \
    qemu-guest-agent \
    cloud-init \
    openssh-server \
    gnome-shell \
    gdm \
    xorg-x11-server-Xorg \
    mesa-dri-drivers \
    gnome-tweaks \
    firefox \
    xdg-user-dirs-gtk \
    NetworkManager-wifi

# Enable required services
sudo systemctl enable gdm
sudo systemctl enable NetworkManager
sudo systemctl set-default graphical.target

# Configure GNOME settings
sudo -u packer dbus-launch gsettings set org.gnome.desktop.interface enable-animations false
sudo -u packer dbus-launch gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'