variable "iso_checksum" {
  type    = string
  default = "sha256:c2e6f4dc37ac944e2ed507f87c6188dd4d3179bf4a3f9e110d3c88d1f3294bdc"
}

variable "vm_name" {
  type    = string
  default = "ubuntu-24.04-x64-desktop"
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

variable "output_directory" {
  type    = string
  default = "output"
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

source "qemu" "ubuntu" {
  iso_urls = [
    "iso/ubuntu-24.04.1-desktop-amd64.iso",
    "https://mirror.arizona.edu/ubuntu-releases/24.04.1/ubuntu-24.04.1-desktop-amd64.iso"
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
    "<wait5><tab><wait>",
    "c<wait>",
    "set gfxpayload=keep<enter><wait>",
    "linux /casper/vmlinuz --- quiet<wait>",
    " autoinstall<wait>",
    " ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/<wait>",
    " fsck.mode=skip<wait>",
    " snap_core=<wait>",
    " snap_core_channel=stable<wait>",
    " console-setup/ask_detect=false<wait>",
    " keyboard-configuration/layoutcode=us<wait>",
    " debconf/priority=critical<wait>",
    " console=tty1<wait>",
    " console=ttyS0<wait>",
    "<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]
  boot_key_interval = "50ms"
  boot_keygroup_interval = "1s"
  
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
  name = "ubuntu-24.04-x64-desktop"
  sources = ["source.qemu.ubuntu"]

  provisioner "shell" {
    inline = ["while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"]
  }

  provisioner "ansible" {
    playbook_file = "templates/${var.vm_name}/ansible/reset-machine-id.yml"
    use_proxy     = false
    user          = var.ssh_username
    extra_arguments = [
      "--extra-vars", 
      "ansible_python_interpreter=/usr/bin/python3 ansible_password=${var.ssh_password} ansible_sudo_pass=${var.ssh_password}"
    ]
  }

  provisioner "ansible" {
    playbook_file = "templates/${var.vm_name}/ansible/reset-ssh-host-keys.yml"
    use_proxy     = false
    user          = var.ssh_username
    extra_arguments = [
      "--extra-vars", 
      "ansible_python_interpreter=/usr/bin/python3 ansible_password=${var.ssh_password} ansible_sudo_pass=${var.ssh_password}"
    ]
  }
}