locals {
  # Detect current workspace (dev or prod). Default to dev if unknown.
  env = terraform.workspace == "default" ? "dev" : terraform.workspace
  
  # Helper to calculate starting IP octet
  base_ip = var.ip_offsets[local.env]
}

# --- K3s Master Node(s) ---
resource "proxmox_vm_qemu" "k3s_master" {
  count       = var.k3s_master_count[local.env]
  name        = "${local.env}-k3s-master-${count.index + 1}"
  target_node = var.proxmox_node
  clone       = var.template_name
  
  # Basic Settings
  agent    = 1
  os_type  = "cloud-init"
  cores    = var.vm_specs[local.env].k3s_cpu
  sockets  = 1
  cpu      = "host"
  memory   = var.vm_specs[local.env].k3s_mem
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    slot = 0
    size = "20G"
    type = "scsi"
    storage = "local-lvm" # Change to your storage ID (e.g., 'local-zfs', 'ceph')
    iothread = 1
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  # Cloud-Init Config
  ciuser  = "ubuntu"
  sshkeys = var.ssh_public_key
  
  # IP Address Calculation: Offset + 0-9 range for Masters
  # Example Dev: 192.168.1.110 (Master 1)
  ipconfig0 = "ip=192.168.1.${local.base_ip + count.index}/24,gw=${var.network_gateway}"
  
  lifecycle {
    ignore_changes = [network]
  }
}

# --- K3s Worker Node(s) ---
resource "proxmox_vm_qemu" "k3s_worker" {
  count       = var.k3s_worker_count[local.env]
  name        = "${local.env}-k3s-worker-${count.index + 1}"
  target_node = var.proxmox_node
  clone       = var.template_name
  
  agent    = 1
  os_type  = "cloud-init"
  cores    = var.vm_specs[local.env].k3s_cpu
  memory   = var.vm_specs[local.env].k3s_mem
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    slot = 0
    size = "20G"
    type = "scsi"
    storage = "local-lvm"
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  ciuser  = "ubuntu"
  sshkeys = var.ssh_public_key

  # IP Address Calculation: Offset + 10-20 range for Workers
  # Example Dev: 192.168.1.120 (Worker 1)
  ipconfig0 = "ip=192.168.1.${local.base_ip + 10 + count.index}/24,gw=${var.network_gateway}"

  lifecycle {
    ignore_changes = [network]
  }
}

# --- Standalone Postgres DB ---
resource "proxmox_vm_qemu" "postgres_db" {
  count       = 1 # Always 1 DB per env
  name        = "${local.env}-postgres-db"
  target_node = var.proxmox_node
  clone       = var.template_name
  
  agent    = 1
  os_type  = "cloud-init"
  cores    = var.vm_specs[local.env].db_cpu
  memory   = var.vm_specs[local.env].db_mem
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    slot = 0
    size = "40G" # Larger disk for DB
    type = "scsi"
    storage = "local-lvm"
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  ciuser  = "ubuntu"
  sshkeys = var.ssh_public_key

  # IP Address Calculation: Offset + 30 for DB
  # Example Dev: 192.168.1.140
  ipconfig0 = "ip=192.168.1.${local.base_ip + 30}/24,gw=${var.network_gateway}"
  
  lifecycle {
    ignore_changes = [network]
  }
}