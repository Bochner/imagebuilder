#!/bin/bash

# Create base output directory
mkdir -p output

# Create template-specific directories
for os in ubuntu kali fedora windows; do
    mkdir -p "output/$os/tmp"
    mkdir -p "output/$os/completed"
done

# Set appropriate permissions
chmod -R 755 output

echo "Directory structure created:"
tree output 