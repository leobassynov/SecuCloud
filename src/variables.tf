variable "prefix" {
  description = "Préfixe utilisé pour nommer les ressources"
  type        = string
  default     = "ynov1"
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Nom du projet"
  type        = string
  default     = "tp-azure"
}

variable "location" {
  description = "Région Azure"
  type        = string
  default     = "swedencentral"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}

variable "vm_size" {
  type    = string
  default = "Standard_B2ts_v2"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_key" {
  description = "Contenu de la clé SSH publique"
  type        = string
}