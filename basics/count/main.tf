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

resource "libvirt_pool" "imagespool" {
  name = "imagespool"
  type = "dir"
  path = "/tmp/libvirt-pool-imagespool"
}

resource "libvirt_volume" "os_image" {
  name   = "os_image"
  source = "http://get.goffinet.org/kvm/centos8.qcow2"
  pool   = libvirt_pool.imagespool.name
  format = "qcow2"
}

resource "libvirt_volume" "volume" {
  name           = "volume-${count.index}"
  base_volume_id = libvirt_volume.os_image.id
  count          = 4
  pool = libvirt_pool.imagespool.name
}

resource "libvirt_domain" "domain" {
  name = "domain-${count.index}"
  memory = "512"
  vcpu   = 1
  disk {
    volume_id = element(libvirt_volume.volume.*.id, count.index)
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

  count = 4
}

output "ips" {
  value = libvirt_domain.domain.*.network_interface.0.addresses
}
