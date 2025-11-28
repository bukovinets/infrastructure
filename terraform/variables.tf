variable "ssh_public_key" {
  type = string
}

variable "proxmox_node" {
  type    = string
  default = "proxmox"
}

variable "template_vm_id" {
  description = "The VM ID of the template to clone (e.g., 9000). Must be a number."
  type        = number
  default     = 100
}

variable "k3s_master_count" {
  type    = map(number)
  default = { dev = 1, prod = 1 }
}

variable "k3s_worker_count" {
  type    = map(number)
  default = { dev = 2, prod = 3 }
}

variable "vm_specs" {
  default = {
    dev  = { k3s_cpu = 2, k3s_mem = 2048, db_cpu = 2, db_mem = 2048 }
    prod = { k3s_cpu = 2, k3s_mem = 2048, db_cpu = 2, db_mem = 2048 }
  }
}

variable "network_prefix" {
  description = "The first 3 octets of the network IP (e.g., 192.168.1)"
  type        = string
  default     = "10.0.0"
}

variable "network_gateway" {
  type    = string
  default = "10.0.0.1"
}

variable "ip_offsets" {
  default = { dev = 150, prod = 180 }
}
