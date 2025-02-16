#!/bin/bash
set -e

# Update package lists and upgrade system
sudo apt-get update
sudo apt-get upgrade -y

# Install essential packages and Kali desktop environment
sudo apt-get install -y \
    qemu-guest-agent \
    openssh-server \
    kali-desktop-xfce \
    kali-linux-default \
    xfce4-terminal \
    firefox-esr \
    network-manager \
    pulseaudio \
    xfce4-pulseaudio-plugin \
    lightdm

# Enable essential services
sudo systemctl enable qemu-guest-agent
sudo systemctl enable lightdm
sudo systemctl enable NetworkManager
sudo systemctl set-default graphical.target

# Configure XFCE settings for packer user
mkdir -p /home/packer/.config/xfce4
sudo chown -R packer:packer /home/packer/.config

# Set up default terminal preferences
mkdir -p /home/packer/.config/xfce4/terminal
cat > /home/packer/.config/xfce4/terminal/terminalrc << EOF
[Configuration]
FontName=Monospace 12
MiscAlwaysShowTabs=FALSE
MiscBell=FALSE
MiscBellUrgent=FALSE
MiscBordersDefault=TRUE
MiscCursorBlinks=FALSE
MiscCursorShape=TERMINAL_CURSOR_SHAPE_BLOCK
MiscDefaultGeometry=80x24
MiscInheritGeometry=FALSE
MiscMenubarDefault=TRUE
MiscMouseAutohide=FALSE
MiscMouseWheelZoom=TRUE
MiscToolbarDefault=FALSE
MiscConfirmClose=TRUE
MiscCycleTabs=TRUE
MiscTabCloseButtons=TRUE
MiscTabCloseMiddleClick=TRUE
MiscTabPosition=GTK_POS_TOP
MiscHighlightUrls=TRUE
MiscMiddleClickOpensUri=FALSE
MiscCopyOnSelect=FALSE
MiscShowRelaunchDialog=TRUE
MiscRewrapOnResize=TRUE
MiscUseShiftArrowsToScroll=FALSE
MiscSlimTabs=FALSE
MiscNewTabAdjacent=FALSE
EOF

sudo chown -R packer:packer /home/packer/.config/xfce4