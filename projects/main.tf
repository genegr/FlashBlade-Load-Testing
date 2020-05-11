provider "libvirt" {
  uri = "qemu+ssh://root@10.225.112.63/system"
}

resource "libvirt_pool" "kvm-ds01" {
  name = "ds01"
  type = "dir"
  path = "/kvm-datastores/datastore01"
}
