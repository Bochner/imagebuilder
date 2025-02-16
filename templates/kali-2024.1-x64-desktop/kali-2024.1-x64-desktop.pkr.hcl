variable "iso_checksum" {
  type    = string
  default = "sha256:beca4f8fd7f58eda290812f538e1323d3ba1f1a34df4b203e85de4be42525bb6"
}

variable "vm_name" {
  type    = string
  default = "kali-2024.1-x64-desktop"
}

variable "headless" {
  type    = bool
  default = false
}

variable "cpu" {
  type    = string
  default = "host"
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "disk_size" {
  type    = string
  default = "40G"
}

variable "vm_cpu_cores" {
  type    = number
  default = 2
}

variable "ssh_username" {
  type    = string
  default = "kali"
}

variable "ssh_password" {
  type    = string
  default = "kali"
}

source "qemu" "kali" {
  iso_urls = [
    "iso/kali-linux-2024.1-installer-amd64.iso",
    "https://cdimage.kali.org/kali-2024.1/kali-linux-2024.1-installer-amd64.iso"
  ]
  iso_checksum = var.iso_checksum
  output_directory  = "output/${var.vm_name}"
  shutdown_command  = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  disk_size         = var.disk_size
  format            = "qcow2"
  accelerator       = "kvm"
  http_directory    = "templates/${var.vm_name}/http"
  
  ssh_username      = var.ssh_username
  ssh_password      = var.ssh_password
  ssh_timeout       = "60m"
  ssh_port          = 22
  ssh_handshake_attempts = 100
  ssh_wait_timeout  = "2h"
  
  vm_name          = var.vm_name
  memory           = var.memory
  cpus             = 2
  headless         = var.headless
  
  boot_wait = "5s"
  boot_command = [
    "<esc><wait>",
    "install <wait>",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>",
    "debian-installer=en_US.UTF-8 <wait>",
    "auto <wait>",
    "locale=en_US.UTF-8 <wait>",
    "kbd-chooser/method=us <wait>",
    "keyboard-configuration/xkb-keymap=us <wait>",
    "netcfg/get_hostname=kali <wait>",
    "netcfg/get_domain=unassigned-domain <wait>",
    "fb=false <wait>",
    "debconf/frontend=noninteractive <wait>",
    "console-setup/ask_detect=false <wait>",
    "console-keymaps-at/keymap=us <wait>",
    "grub-installer/bootdev=/dev/vda <wait>",
    "<enter><wait>"
  ]
  
  disk_interface   = "virtio"
  net_device      = "virtio-net"
  machine_type    = "q35"
  
  qemuargs = [
    ["-cpu", "host"],
    ["-machine", "type=q35,accel=kvm"],
    ["-device", "virtio-net,netdev=user.0"],
    ["-netdev", "user,id=user.0,hostfwd=tcp::{{ .SSHHostPort }}-:22"],
    ["-device", "virtio-serial-pci"],
    ["-device", "virtserialport,chardev=qga0,name=org.qemu.guest_agent.0"],
    ["-chardev", "socket,path=/tmp/qga.sock,server,nowait,id=qga0"],
    ["-device", "qemu-xhci"],
    ["-device", "virtio-tablet"],
    ["-device", "virtio-keyboard"],
    ["-device", "virtio-gpu-pci"],
    ["-spice", "port=5930,disable-ticketing=on"],
    ["-device", "virtio-serial-pci"],
    ["-chardev", "spicevmc,id=vdagent,name=vdagent"],
    ["-device", "virtserialport,chardev=vdagent,name=com.redhat.spice.0"]
  ]
}

build {
  name = "kali-2024.1-x64-desktop"
  sources = ["source.qemu.kali"]
} 