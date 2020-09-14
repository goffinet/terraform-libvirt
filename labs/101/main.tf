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
  lab_name = "101"
  memory = "512"
  image_url = "http://get.goffinet.org/kvm/centos7.qcow2"
}

resource "libvirt_pool" "lab_image_pool" {
  name = "lab${local.lab_name}_image_pool"
  type = "dir"
  path = "/tmp/lab${local.lab_name}-image-pool"
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  pool           = libvirt_pool.lab_image_pool.name
}

resource "libvirt_network" "lan" {
  name = "lan-${local.lab_name}"
  mode = "none"
}

resource "libvirt_volume" "os_image" {
  name   = "lab${local.lab_name}-os_image_image"
  source = local.image_url
  pool   = libvirt_pool.lab_image_pool.name
  format = "qcow2"
}

resource "libvirt_volume" "volume" {
  name           = "lab${local.lab_name}-volume-${count.index}"
  base_volume_id = libvirt_volume.os_image.id
  count          = 2
  pool = libvirt_pool.lab_image_pool.name
}

resource "libvirt_domain" "pc" {
  name = "pc1-${local.lab_name}"
  memory = local.memory
  vcpu   = 1
  disk {
    volume_id = libvirt_volume.volume.0.id
  }

  network_interface {
    network_id     = libvirt_network.lan.id
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

resource "libvirt_domain" "router" {
  name = "r${local.lab_name}"
  memory = local.memory
  vcpu   = 1
  cloudinit = libvirt_cloudinit_disk.commoninit.id

  disk {
    volume_id = libvirt_volume.volume.1.id
  }

  network_interface {
    network_id     = libvirt_network.lan.id
    wait_for_lease = false
  }

  network_interface {
    network_name   = "default"
    wait_for_lease = true
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
