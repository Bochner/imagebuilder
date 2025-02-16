#!/bin/bash
set -e

# Clean package cache
sudo apt-get clean
sudo apt-get autoremove -y

# Clear logs
sudo rm -rf /var/log/*.log
sudo rm -rf /var/log/apt/*
sudo rm -rf /var/cache/apt/*

# Clear bash history
cat /dev/null > ~/.bash_history && history -c