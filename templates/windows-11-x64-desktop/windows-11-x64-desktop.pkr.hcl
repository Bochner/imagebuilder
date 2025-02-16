variable "iso_checksum" {
  type    = string
  default = "sha256:ebbc79106715f44f5596d0478fceb8ca2d7dc6f0c1a7716c45991c49731e88de"
}

variable "vm_name" {
  type    = string
  default = "windows-11-x64-desktop"
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
  default = "80G"
}

variable "vm_cpu_cores" {
  type    = number
  default = 2
}

variable "winrm_username" {
  type    = string
  default = "Administrator"
}

variable "winrm_password" {
  type    = string
  default = "password"
}

source "qemu" "windows" {
  iso_urls = [
    "iso/Windows.iso",
    "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"
  ]
  iso_checksum = var.iso_checksum
  output_directory  = "output/${var.vm_name}"
  shutdown_command  = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  disk_size         = var.disk_size
  format            = "qcow2"
  accelerator       = "kvm"
  http_directory    = "templates/${var.vm_name}/http"
  
  communicator     = "winrm"
  winrm_username   = var.winrm_username
  winrm_password   = var.winrm_password
  winrm_timeout    = "2h"
  
  vm_name          = var.vm_name
  memory           = var.memory
  cpus             = 2
  headless         = var.headless
  
  boot_wait = "5s"
  boot_command = [
    "<enter><wait2m>"
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
  name = "windows-11-x64-desktop"
  sources = ["source.qemu.windows"]

  provisioner "powershell" {
    scripts = [
      "templates/${var.vm_name}/scripts/enable-winrm.ps1",
      "templates/${var.vm_name}/scripts/install-virtio-drivers.ps1",
      "templates/${var.vm_name}/scripts/optimize-windows.ps1",
      "templates/${var.vm_name}/scripts/disable-windows-updates.ps1"
    ]
  }
} 