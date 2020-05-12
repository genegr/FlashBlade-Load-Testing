variable "libvirt_endpoint" {
  type = string
  default = "qemu+ssh://root@10.225.112.63/system"
}

variable "instance_name" {
  type = string
  default = "mysql-tmpl"
}

variable "centos_cloud_image" {
  type = string
#  default = "http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  default = "images/CentOS-7-x86_64-GenericCloud.qcow2"
}

variable "templates_pool" {
  type = string
  default = "templates"
}

variable "data_disk_sz" {
  type = number
  default = 64424509440
}

variable "domainname" {
  type = string
  default = "uklab.purestorage.com"
}

variable "basedir" {
  type = string
  default = "/kvm-datastores"
}

variable "datastores" {
  type = list
  default = ["templates", "datastore01", "datastore02"]
}

variable "sysbench_ntables" {
  type = number
  default = 10
}

variable "sysbench_tablesz" {
  type = number
  default = 100
}
