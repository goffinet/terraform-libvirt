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

locals {
  count = 4
  lab_name = "103"
  router_memory = "512"
  router_image_url = "http://get.goffinet.org/kvm/centos7.qcow2"
  pc_memory = "512"
  pc_image_url = "http://get.goffinet.org/kvm/focal.qcow2"
}

resource "libvirt_pool" "lab_image_pool" {
  name = "lab${local.lab_name}_image_pool"
  type = "dir"
  path = "/tmp/lab${local.lab_name}-image-pool"
}

data "template_file" "router_user_data" {
  count = local.count
  template = "${file("${path.module}/router_cloud_init.cfg")}"
  vars = {
    id = "${count.index + 1}"
  }
}

resource "libvirt_cloudinit_disk" "router_commoninit" {
  count = local.count
  name           = "router-commoninit${count.index + 1}.iso"
  user_data      = data.template_file.router_user_data[count.index].rendered
  pool           = libvirt_pool.lab_image_pool.name
}

resource "libvirt_volume" "router_os_image" {
  name   = "router${local.lab_name}-os_image"
  source = local.router_image_url
  pool   = libvirt_pool.lab_image_pool.name
  format = "qcow2"
}

resource "libvirt_volume" "router_volume" {
  name           = "router${local.lab_name}_volume-${count.index + 1}"
  base_volume_id = libvirt_volume.router_os_image.id
  count          = local.count
  pool = libvirt_pool.lab_image_pool.name
}

resource "libvirt_volume" "pc_os_image" {
  name   = "pc${local.lab_name}-os_image"
  source = local.pc_image_url
  pool   = libvirt_pool.lab_image_pool.name
  format = "qcow2"
}

resource "libvirt_volume" "pc_volume" {
  name           = "pc${local.lab_name}_volume-${count.index + 1}"
  base_volume_id = libvirt_volume.pc_os_image.id
  count          = local.count
  pool = libvirt_pool.lab_image_pool.name
}

resource "libvirt_network" "lan" {
  name = "lan${count.index + 1}-${local.lab_name}"
  mode = "none"
  bridge = "lan${count.index + 1}-${local.lab_name}"
  autostart = true
  count = local.count
}

resource "libvirt_network" "wan" {
  name = "wan${local.lab_name}"
  mode = "none"
  autostart = true
}

resource "libvirt_domain" "router" {
  count = local.count
  name = "r${count.index + 1}-${local.lab_name}"
  memory = local.router_memory
  vcpu   = 1
  qemu_agent = true
  cloudinit = element(libvirt_cloudinit_disk.router_commoninit.*.id, count.index)
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
  count = local.count
  name = "pc${count.index + 1}-${local.lab_name}"
  memory = local.pc_memory
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
