# instance the provider
provider "libvirt" {
  uri = var.libvirt_endpoint
}

resource "libvirt_pool" "datastore" {
  count  = length(var.datastores)
  name   = element(var.datastores, count.index)
  type = "dir"
  path = "${var.basedir}/${element(var.datastores, count.index)}"
}

# fetch the latest CentOS7 release image from their mirrors
# and create root disk
resource "libvirt_volume" "centos-qcow2-root" {
  name   = "${var.instance_name}-root"
  pool   = var.templates_pool
  source = var.centos_cloud_image
  format = "qcow2"
}

# allocate the data disk
resource "libvirt_volume" "centos-qcow2-data" {
  name   = "${var.instance_name}-data"
  pool   = var.templates_pool
  format = "qcow2"
  size   = var.data_disk_sz
}

# define cloud-init resources
data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    hostname = var.instance_name
    fqdn: "${var.instance_name}.${var.domainname}"
    sysbench_ntables: var.sysbench_ntables
    sysbench_tablesz: var.sysbench_tablesz
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "${var.instance_name}-commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = var.templates_pool
}

# create the machine
resource "libvirt_domain" "centos7-instance" {
  name   = var.instance_name
  memory = "4096"
  vcpu   = 4

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = "default"
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
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

  disk {
    volume_id = libvirt_volume.centos-qcow2-root.id
  }

  disk {
    volume_id = libvirt_volume.centos-qcow2-data.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

terraform {
  required_version = ">= 0.12"
}
