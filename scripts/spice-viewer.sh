#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create a lock file
LOCK_FILE="/tmp/spice_viewer.lock"

# Check if lock file exists and process is still running
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo -e "${YELLOW}SPICE viewer is already running (PID: $PID)${NC}"
        exit 0
    else
        # Clean up stale lock file
        rm -f "$LOCK_FILE"
    fi
fi

# Store current PID in lock file
echo $$ > "$LOCK_FILE"

# Cleanup function
cleanup() {
    rm -f "$LOCK_FILE"
    exit 0
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

# Check if spice-viewer is installed
if ! command -v remote-viewer &>/dev/null; then
    echo -e "${YELLOW}Installing virt-viewer (includes spice-viewer)...${NC}"
    sudo dnf install -y virt-viewer
fi

# Kill any existing remote-viewer processes
pkill -f "remote-viewer spice://127.0.0.1:5930" >/dev/null 2>&1

echo -e "${GREEN}Waiting for QEMU to start...${NC}"
# Wait for QEMU to start and open the SPICE port
while ! netstat -tuln | grep ":5930" > /dev/null; do
    sleep 1
done

echo -e "${GREEN}QEMU detected, launching SPICE viewer...${NC}"
sleep 2  # Give QEMU a moment to fully initialize SPICE

# Launch viewer in background
nohup remote-viewer spice://127.0.0.1:5930 >/dev/null 2>&1 &
VIEWER_PID=$!

# Wait for viewer to start
sleep 1

echo -e "${GREEN}SPICE viewer launched (PID: $VIEWER_PID)${NC}"
echo -e "${YELLOW}Note: The build will continue even if you close the viewer.${NC}"

# Keep script running until viewer exits
wait $VIEWER_PID

# Exit cleanly
exit 0 