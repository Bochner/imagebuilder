#!/bin/bash
set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Parse command line arguments
USE_SPICE=0
TEMPLATE=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --spice|-s) USE_SPICE=1 ;;
        --template|-t) TEMPLATE="$2"; shift ;;
        ubuntu|kali|fedora|windows) TEMPLATE="$1" ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

echo -e "${GREEN}==> Checking system requirements...${NC}"

# Check if running with sudo/root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}Please do not run this script as root/sudo${NC}"
    exit 1
fi

# Check for required packages
REQUIRED_PKGS="qemu-kvm libvirt virt-install bridge-utils wget curl packer ansible"
MISSING_PKGS=""

for pkg in $REQUIRED_PKGS; do
    if ! rpm -q "$pkg" &>/dev/null; then
        MISSING_PKGS="$MISSING_PKGS $pkg"
    fi
done

if [ ! -z "$MISSING_PKGS" ]; then
    echo -e "${YELLOW}Installing missing packages:${NC}$MISSING_PKGS"
    sudo dnf install -y $MISSING_PKGS
fi

# Verify Ansible installation
if ! command -v ansible-playbook &>/dev/null; then
    echo -e "${RED}Error: ansible-playbook command not found${NC}"
    echo -e "${YELLOW}Installing Ansible...${NC}"
    sudo dnf install -y ansible
fi

# Check required directory structure
echo -e "${GREEN}==> Checking directory structure...${NC}"
mkdir -p output iso

# Check virtualization support
if ! grep -q -E 'vmx|svm' /proc/cpuinfo; then
    echo -e "${RED}Error: CPU virtualization not enabled in BIOS${NC}"
    exit 1
fi

# Check minimum system resources
MIN_RAM_GB=12
AVAILABLE_RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
if [ $AVAILABLE_RAM_GB -lt $MIN_RAM_GB ]; then
    echo -e "${YELLOW}Warning: Less than ${MIN_RAM_GB}GB RAM available. Builds might be slow.${NC}"
fi

# Check libvirt configuration
echo -e "${GREEN}==> Checking libvirt configuration...${NC}"
if ! systemctl is-active --quiet libvirtd; then
    echo -e "${YELLOW}Starting libvirt daemon...${NC}"
    sudo systemctl start libvirtd
fi

# Ensure default network is active and enable virsh access
sudo virsh net-list &>/dev/null || {
    echo -e "${YELLOW}Starting default network...${NC}"
    sudo virsh net-define /usr/share/libvirt/networks/default.xml
    sudo virsh net-start default
    sudo virsh net-autostart default
}

# Set SELinux context if enabled
if command -v selinuxenabled >/dev/null && selinuxenabled; then
    echo -e "${GREEN}==> Setting SELinux context for directories...${NC}"
    sudo chcon -Rt svirt_image_t iso/
    sudo chcon -Rt svirt_image_t output/
fi

# Function to download ISO with proper progress display
download_iso() {
    local url=$1
    local output=$2
    echo -e "${YELLOW}Downloading ISO from: ${url}${NC}"
    wget --progress=bar:force -O "$output" "$url" 2>&1 | stdbuf -o0 tr '\r' '\n'
}

# Function to check if template needs building
check_template() {
    local template=$1
    local completed_file="output/${template}/${template}.qcow2"
    local iso_file
    local iso_url
    
    case $template in
        "ubuntu-24.04-x64-desktop")
            iso_file="iso/ubuntu-24.04.1-desktop-amd64.iso"
            iso_url="https://mirror.arizona.edu/ubuntu-releases/24.04.1/ubuntu-24.04.1-desktop-amd64.iso"
            ;;
        "kali-2024.1-x64-desktop")
            iso_file="iso/kali-linux-2024.1-installer-amd64.iso"
            iso_url="https://cdimage.kali.org/kali-2024.1/kali-linux-2024.1-installer-amd64.iso"
            ;;
        "fedora-41-x64-desktop")
            iso_file="iso/Fedora-Workstation-Live-x86_64-41-1.4.iso"
            iso_url="https://download.fedoraproject.org/pub/fedora/linux/releases/41/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-41-1.4.iso"
            ;;
        "windows-11-x64-desktop")
            iso_file="iso/Windows.iso"
            iso_url="https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"
            ;;
        *)
            echo -e "${RED}Unknown template: $template${NC}"
            return 1
            ;;
    esac
    
    if [ -f "${completed_file}" ]; then
        echo -e "${YELLOW}Template ${template} already exists at ${completed_file}, skipping...${NC}"
        return 1
    fi

    # Check for ISO and download if needed
    if [ ! -f "$iso_file" ]; then
        echo -e "${YELLOW}Downloading ${template} ISO...${NC}"
        download_iso "$iso_url" "$iso_file"
    fi

    return 0
}

# Function to launch SPICE viewer
launch_spice() {
    setsid ./scripts/spice-viewer.sh &
}

# Function to build a specific template
build_template() {
    local template=$1
    
    if ! check_template "$template"; then
        return 0
    fi
    
    echo -e "${GREEN}Building ${template} template...${NC}"
    
    # Launch SPICE if requested
    if [ $USE_SPICE -eq 1 ]; then
        launch_spice
    fi
    
    if PACKER_LOG=1 packer build "templates/${template}/${template}.pkr.hcl"; then
        echo -e "${GREEN}Template built successfully at output/${template}/${template}.qcow2${NC}"
    else
        echo -e "${RED}Build failed for ${template}${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Completed building ${template}${NC}"
}

# Run the build
if [ -n "$TEMPLATE" ]; then
    case $TEMPLATE in
        ubuntu) TEMPLATE="ubuntu-24.04-x64-desktop" ;;
        kali) TEMPLATE="kali-2024.1-x64-desktop" ;;
        fedora) TEMPLATE="fedora-41-x64-desktop" ;;
        windows) TEMPLATE="windows-11-x64-desktop" ;;
    esac
    build_template "$TEMPLATE"
else
    echo -e "${GREEN}==> Running all template builds...${NC}"
    for template in ubuntu-24.04-x64-desktop kali-2024.1-x64-desktop fedora-41-x64-desktop windows-11-x64-desktop; do
        build_template "$template"
    done
fi