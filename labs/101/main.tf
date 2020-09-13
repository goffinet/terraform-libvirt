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

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  pool           = libvirt_pool.lab101_image_pool.name
}

resource "libvirt_network" "lan101" {
  name = "lan101"
  mode = "none"
}

resource "libvirt_pool" "lab101_image_pool" {
  name = "os_image-image-pool"
  type = "dir"
  path = "/tmp/lab101-image-pool"
}

resource "libvirt_volume" "os_image" {
  name   = "os_image_image"
  source = "http://get.goffinet.org/kvm/centos7.qcow2"
  pool   = libvirt_pool.lab101_image_pool.name
  format = "qcow2"
}

resource "libvirt_volume" "volume" {
  name           = "volume-${count.index}"
  base_volume_id = libvirt_volume.os_image.id
  count          = 2
  pool = libvirt_pool.lab101_image_pool.name
}

resource "libvirt_domain" "pc1" {
  name = "pc1-101"
  memory = "512"
  vcpu   = 1
  disk {
    volume_id = libvirt_volume.volume.0.id
  }

  network_interface {
    network_id     = libvirt_network.lan101.id
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
  name = "r101"
  memory = "512"
  vcpu   = 1
  cloudinit = libvirt_cloudinit_disk.commoninit.id

  disk {
    volume_id = libvirt_volume.volume.1.id
  }

  network_interface {
    network_id     = libvirt_network.lan101.id
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
