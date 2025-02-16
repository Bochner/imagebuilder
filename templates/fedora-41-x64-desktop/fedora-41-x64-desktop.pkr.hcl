variable "iso_checksum" {
  type    = string
  default = "sha256:a2dd3caf3224b8f3a640d9e31b1016d2a4e98a6d7cb435a1e2030235976d6da2"
}

variable "vm_name" {
  type    = string
  default = "fedora-41-x64-desktop"
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
  default = "localuser"
}

variable "ssh_password" {
  type    = string
  default = "password"
}

source "qemu" "fedora" {
  iso_urls = [
    "iso/Fedora-Workstation-Live-x86_64-41-1.4.iso",
    "https://download.fedoraproject.org/pub/fedora/linux/releases/41/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-41-1.4.iso"
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
  
  boot_wait = "6s"
  boot_command = [
    "e<wait>",
    "<down><down><down><end>",
    "<leftCtrlOn>k<leftCtrlOff>",
    "linux /images/pxeboot/vmlinuz initrd /images/pxeboot/initrd.img -- text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter>",
    "<leftCtrlOn>x<leftCtrlOff>"
  ]
  
  machine_type    = "q35"
  
  qemuargs = [
    ["-cpu", "host"],
    ["-machine", "type=q35,accel=kvm"],
    ["-device", "virtio-net,netdev=user.0"],
    ["-netdev", "user,id=user.0,hostfwd=tcp::{{ .SSHHostPort }}-:22"],
    ["-device", "virtio-serial-pci"],
    ["-device", "virtserialport,chardev=qga0,name=org.qemu.guest_agent.0"],
    ["-chardev", "socket,path=/tmp/qga.sock,server=on,wait=off,id=qga0"],
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
  name = "fedora-41-x64-desktop"
  sources = ["source.qemu.fedora"]
}