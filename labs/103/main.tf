terraform {
 required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.2"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

variable "counter" {
  default = 4
}

data "template_file" "user_data" {
  count = var.counter
  template = "${file("${path.module}/cloud_init.cfg")}"
  vars = {
    id = "${count.index + 1}"
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count = var.counter
  name           = "commoninit${count.index + 1}.iso"
  user_data      = data.template_file.user_data[count.index].rendered
  pool           = libvirt_pool.lab103_image_pool.name
}

resource "libvirt_pool" "lab103_image_pool" {
  name = "lab103_image_pool"
  type = "dir"
  path = "/tmp/lab103-image-pool"
}

resource "libvirt_volume" "os_image" {
  name   = "os_image"
  source = "http://get.goffinet.org/kvm/centos7.qcow2"
  pool   = libvirt_pool.lab103_image_pool.name
  format = "qcow2"
}

resource "libvirt_volume" "router_volume" {
  name           = "router_volume-${count.index + 1}"
  base_volume_id = libvirt_volume.os_image.id
  count          = var.counter
  pool = libvirt_pool.lab103_image_pool.name
}

resource "libvirt_volume" "pc_volume" {
  name           = "pc_volume-${count.index + 1}"
  base_volume_id = libvirt_volume.os_image.id
  count          = var.counter
  pool = libvirt_pool.lab103_image_pool.name
}

resource "libvirt_network" "lan" {
  name = "lan${count.index + 1}-103"
  mode = "none"
  bridge = "lan${count.index + 1}-103"
  autostart = true
  count = var.counter
}

resource "libvirt_network" "wan" {
  name = "wan103"
  mode = "none"
  autostart = true
}

resource "libvirt_domain" "router" {
  count = var.counter
  name = "r${count.index + 1}-103"
  memory = "512"
  vcpu   = 1
  qemu_agent = true
  cloudinit = element(libvirt_cloudinit_disk.commoninit.*.id, count.index)
  disk {
    volume_id = element(libvirt_volume.router_volume.*.id, count.index)
  }

  network_interface {
    network_id  = element(libvirt_network.lan.*.id, count.index)
    wait_for_lease = false
  }

  network_interface {
    network_id     = libvirt_network.wan.id
    wait_for_lease = false
  }

  network_interface {
    network_name   = "default"
    wait_for_lease = false
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }
}

resource "libvirt_domain" "pc" {
  count = var.counter
  name = "pc${count.index + 1}-103"
  memory = "512"
  vcpu   = 1
  qemu_agent = true
  disk {
    volume_id = element(libvirt_volume.pc_volume.*.id, count.index)
  }

  network_interface {
    network_id  = element(libvirt_network.lan.*.id, count.index)
    wait_for_lease = false
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

}
