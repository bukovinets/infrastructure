locals {
  env = terraform.workspace == "default" ? "dev" : terraform.workspace
  base_ip = var.ip_offsets[local.env]
}

# --- K3s Master Node(s) ---
resource "proxmox_virtual_environment_vm" "k3s_master" {
  count     = var.k3s_master_count[local.env]
  name      = "${local.env}-k3s-master-${count.index + 1}"
  node_name = var.proxmox_node
  
  on_boot = true
  started = true

  clone {
    vm_id = var.template_vm_id
  }

  agent {
    enabled = false
  }

  cpu {
    cores = var.vm_specs[local.env].k3s_cpu
    type  = "host"
  }

  memory {
    dedicated = var.vm_specs[local.env].k3s_mem
  }

  disk {
    datastore_id = var.proxmox_storage
    interface    = "scsi0"
    size         = 50
    file_format  = "qcow2"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${var.network_prefix}.${local.base_ip + count.index}/24"
        gateway = var.network_gateway
      }
    }
    
    dns {
      servers = [var.network_dns]
    }
    
    user_account {
      username = "ubuntu"
      keys     = [var.ssh_public_key]
    }
  }
}

# --- K3s Worker Node(s) ---
resource "proxmox_virtual_environment_vm" "k3s_worker" {
  count     = var.k3s_worker_count[local.env]
  name      = "${local.env}-k3s-worker-${count.index + 1}"
  node_name = var.proxmox_node

  depends_on = [proxmox_virtual_environment_vm.k3s_master]

  on_boot = true
  started = true
  
  clone {
    vm_id = var.template_vm_id
  }

  agent { enabled = false }

  cpu {
    cores = var.vm_specs[local.env].k3s_cpu
    type  = "host"
  }

  memory {
    dedicated = var.vm_specs[local.env].k3s_mem
  }

  disk {
    datastore_id = var.proxmox_storage
    interface    = "scsi0"
    size         = 50
    file_format  = "qcow2"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${var.network_prefix}.${local.base_ip + 10 + count.index}/24"
        gateway = var.network_gateway
      }
    }
    
    dns {
      servers = [var.network_dns]
    }

    user_account {
      username = "ubuntu"
      keys     = [var.ssh_public_key]
    }
  }
}

# --- Postgres DB ---
resource "proxmox_virtual_environment_vm" "postgres_db" {
  count     = 1
  name      = "${local.env}-postgres-db"
  node_name = var.proxmox_node

  depends_on = [proxmox_virtual_environment_vm.k3s_worker]

  on_boot = true
  started = true
  
  clone {
    vm_id = var.template_vm_id
  }

  agent { enabled = false }

  cpu {
    cores = var.vm_specs[local.env].db_cpu
    type  = "host"
  }

  memory {
    dedicated = var.vm_specs[local.env].db_mem
  }

  disk {
    datastore_id = var.proxmox_storage
    interface    = "scsi0"
    size         = 50
    file_format  = "qcow2"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${var.network_prefix}.${local.base_ip + 30}/24"
        gateway = var.network_gateway
      }
    }
    
    dns {
      servers = [var.network_dns]
    }

    user_account {
      username = "ubuntu"
      keys     = [var.ssh_public_key]
    }
  }
}