#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Function to draw a box
draw_box() {
    local title="$1"
    local content="$2"
    echo -e "${BOLD}╭─ $title ─${NC}"
    echo -e "$content" | sed 's/^/│ /'
    echo -e "${BOLD}╰─${NC}"
}

# Function to format process info
format_process() {
    echo "$1" | awk '{printf "%-6s %-40s\n", $1, $2" "$3" "$4}'
}

# Function to format network info
format_network() {
    echo "$1" | awk '{printf "%-20s %-20s %-20s\n", $4, $5, $7}'
}

# Clear screen once at start
clear

# Hide cursor
tput civis

# Restore cursor on exit
trap 'tput cnorm' EXIT

while true; do
    # Save cursor position
    tput sc

    # Move to top of screen
    tput cup 0 0

    echo -e "${GREEN}${BOLD}QEMU Build Monitor${NC} ${DIM}(Press Ctrl+C to exit)${NC}\n"

    # QEMU Processes
    processes=$(ps aux | grep "[q]emu" | awk '{print $2 " " $11 " " $12 " " $13}')
    if [ ! -z "$processes" ]; then
        formatted_processes=$(format_process "$processes")
        draw_box "QEMU Processes" "$formatted_processes"
    else
        draw_box "QEMU Processes" "${DIM}No QEMU processes running${NC}"
    fi
    echo

    # Network Ports
    ports=$(sudo ss -tulpn | grep -E '(qemu|LISTEN)' | grep -v grep)
    if [ ! -z "$ports" ]; then
        formatted_ports=$(format_network "$ports")
        draw_box "Network Ports" "$formatted_ports"
    else
        draw_box "Network Ports" "${DIM}No ports in use${NC}"
    fi
    echo

    # Show disk usage of output directory with correct path
    echo -e "\n${GREEN}Output directory size:${NC}"
    du -sh output/kali-2024.4-x64-desktop-template/ 2>/dev/null || echo "Output directory not created yet"

    # SSH Forwarding
    ssh_ports=$(sudo netstat -tlpn | grep -E '(ssh|:22)' | awk '{print $4}')
    if [ ! -z "$ssh_ports" ]; then
        draw_box "SSH Forwarding" "$ssh_ports"
    else
        draw_box "SSH Forwarding" "${DIM}No SSH ports forwarded${NC}"
    fi
    echo

    # QEMU Monitor Sockets
    sockets=$(ls -l /tmp/packer-plugin* 2>/dev/null)
    if [ ! -z "$sockets" ]; then
        draw_box "Monitor Sockets" "$(echo "$sockets" | awk '{print $9}')"
    else
        draw_box "Monitor Sockets" "${DIM}No monitor sockets found${NC}"
    fi
    echo

    # Packer Logs
    if [ -f "packer.log" ]; then
        recent_logs=$(tail -n 3 packer.log | sed 's/\x1b\[[0-9;]*m//g')
        draw_box "Recent Packer Logs" "$recent_logs"
    fi

    # Restore cursor position
    tput rc

    sleep 2
done 