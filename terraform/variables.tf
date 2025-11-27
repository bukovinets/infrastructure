# --- General Settings ---
variable "ssh_public_key" {
  description = "Public SSH key to inject into VMs for Ansible access"
  type        = string
}

variable "proxmox_node" {
  description = "Name of the Proxmox node to deploy to"
  type        = string
  default     = "proxmox"
}

variable "template_name" {
  description = "Name of the Cloud-Init template in Proxmox"
  type        = string
  default     = "Ubuntu-template"
}

# --- Resource Sizing (Per Workspace) ---
variable "k3s_master_count" {
  description = "Number of Master nodes"
  type        = map(number)
  default = {
    dev  = 1
    prod = 1 # Keep 1 for simple clusters, 3 for HA
  }
}

variable "k3s_worker_count" {
  description = "Number of Worker nodes"
  type        = map(number)
  default = {
    dev  = 2
    prod = 3
  }
}

variable "vm_specs" {
  description = "Map of resource specs per environment"
  default = {
    dev = {
      k3s_cpu = 2
      k3s_mem = 2048
      db_cpu  = 2
      db_mem  = 2048
    }
    prod = {
      k3s_cpu = 2
      k3s_mem = 2048
      db_cpu  = 2
      db_mem  = 2048
    }
  }
}

# --- Networking ---
variable "network_gateway" {
  type    = string
  default = "10.0.0.1"
}

# IP Prefixes help generate static IPs automatically
# e.g., Dev K3s Master = 192.168.1.110, Prod K3s Master = 192.168.1.120
variable "ip_offsets" {
  default = {
    dev  = 130
    prod = 180
  }
}