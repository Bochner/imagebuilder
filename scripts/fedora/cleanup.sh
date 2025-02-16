#!/bin/bash
set -e

# Clean DNF caches
sudo dnf clean all

# Remove temporary files
sudo rm -rf /tmp/*

# Clear audit logs
sudo rm -f /var/log/*.log
sudo rm -f /var/log/audit/*

# Clear bash history
cat /dev/null > ~/.bash_history && history -c