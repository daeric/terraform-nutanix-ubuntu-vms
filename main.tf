terraform {
  required_providers {
    nutanix = {
      source = "nutanix/nutanix"
      version = ">=1.7.1"
    }
  }
}

provider "nutanix" {
  username            = var.user
  password            = var.password
  endpoint            = var.endpoint
  port                = 9440
  insecure            = true
  wait_timeout        = 10
  foundation_endpoint = var.foundation_endpoint
  foundation_port     = var.foundation_port
}

resource "nutanix_virtual_machine" "instance" {
  count                = "${var.instance_count}"
  name                 = "hashi-${count.index}"
  cluster_uuid         = data.nutanix_cluster.cluster.id
  num_vcpus_per_socket = "2"
  num_sockets          = "1"
  memory_size_mib      = 4096

  guest_customization_cloud_init_user_data = base64encode(templatefile("${path.module}/resources/cloud-init/generic_pw.tpl", { hostname = "hashi-${count.index}" }))

  disk_list {    
    disk_size_bytes = 104857600000
    disk_size_mib   = 100000
    data_source_reference = {
        kind = "image"
        uuid = "7c924299-c6fa-4a2a-886e-00ee4bc914ce"
      }
    }

  nic_list {
    subnet_uuid = data.nutanix_subnet.subnet.id
  }
}
