variable "proxmox_api_url" {
  type = string
  description = "Format: https://10.0.0.11:8006/api2/json/"
}

variable "proxmox_api_token" {
  type = string
  sensitive = true
  description = "Format: USER@REALM!TOKENID=UUID"
}

provider "proxmox" {
  endpoint = var.proxmox_api_url
  api_token = var.proxmox_api_token
  
  # Ignore self-signed certs
  insecure = true
  
  # Optimization for Proxmox 9
  ssh {
    agent = true
  }
}