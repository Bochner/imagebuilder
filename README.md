# Multi-OS Packer Image Builder

This project uses HashiCorp Packer to automatically build QCOW2 images for multiple operating systems:
- Kali Linux
- Windows 11
- Ubuntu
- Fedora

## Prerequisites

- HashiCorp Packer (>= 1.8.0)
- QEMU/KVM installed on your system
- At least 50GB of free disk space
- Internet connection for downloading ISO files
- Windows 11 ISO (see Windows ISO Setup section below)

## Windows ISO Setup

Since Windows 11 requires authentication to download, you'll need to:

1. Visit the official Windows 11 download page: https://www.microsoft.com/software-download/windows11
2. Download the Windows 11 24H2 64-bit ISO
3. Place the downloaded ISO in the `iso` directory as `Win11_24H2_English_x64.iso`

Note: The SHA256 checksum for the Windows 11 24H2 ISO will need to be updated in `configs/windows.pkr.hcl` once you've downloaded the ISO.

## Project Structure

```
.
├── ansible/          # Ansible playbooks for configuration
├── configs/          # OS-specific configuration files
├── http/            # HTTP server files for automated installation
├── scripts/         # Post-installation scripts
├── iso/             # Directory for OS installation ISOs
├── output/          # Build output directory
│   ├── ubuntu/      # Ubuntu build directory
│   ├── kali/        # Kali build directory
│   ├── fedora/      # Fedora build directory
│   └── windows/     # Windows build directory
└── completed/       # Completed template storage
```

## Quick Start

1. Install required packages:
   ```bash
   sudo dnf update
   sudo dnf install qemu-kvm libvirt virt-install bridge-utils wget curl packer ansible
   ```

2. Run the build script:
   ```bash
   ./build.sh
   ```

   Options:
   - `--spice` or `-s`: Enable SPICE viewer for graphical console

   Build a specific template:
   ```bash
   ./build.sh ubuntu    # Build only Ubuntu template
   ./build.sh kali      # Build only Kali template
   ```

## Build Process

The build process follows these steps:

1. Checks system requirements and dependencies
2. Creates necessary directory structure
3. Downloads ISO files if not present
4. Builds each template using Packer
5. Moves completed templates to the `completed` directory
6. Cleans up build directories after successful completion

Templates are stored in the `completed` directory with standardized names:
- `ubuntu-template.qcow2`
- `kali-template.qcow2`
- `fedora-template.qcow2`
- `windows-template.qcow2`

## Image Details

### Ubuntu
- Based on Ubuntu 24.04 LTS Desktop (Noble Numbat)
- Full desktop installation with GNOME
- Cloud-init ready

### Fedora
- Based on Fedora 41 Workstation
- Full GNOME desktop installation
- Cloud-init ready

### Kali Linux
- Based on Kali Linux 2024.1
- Full desktop installation with default tools
- Cloud-init and SSH enabled

### Windows 11
- Based on Windows 11 Pro (24H2)
- Full desktop installation
- WinRM enabled
- Hardware-accelerated with QEMU/KVM optimizations

## Configuration

Each OS has its own configuration file in the `configs` directory. You can customize:
- CPU and memory allocation
- Disk size
- Network settings
- Installation options

Common settings are stored in `configs/common.pkrvars.hcl`.

## Contributing

Feel free to submit issues and enhancement requests!

## License

MIT License - feel free to use and modify as needed.