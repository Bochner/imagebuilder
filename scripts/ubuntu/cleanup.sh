#!/bin/bash
set -e

# Remove unnecessary packages
sudo apt-get autoremove -y
sudo apt-get clean

# Clear audit logs
sudo rm -rf /var/log/*.log /var/log/apt/* /var/log/auth* /var/log/daemon* /var/log/debug* /var/log/dmesg* /var/log/dpkg* /var/log/kern* /var/log/syslog*

# Clear bash history
cat /dev/null > ~/.bash_history && history -c