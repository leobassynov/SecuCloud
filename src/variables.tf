variable "prefix" {
  default = "lbass" # A personnaliser avec votre nom
}

variable "environment" {
  default = "demo"
}

variable "project" {
  default = "ynov1"
}

variable "ssh_key" {
  description = "Clé publique SSH"
  type = string
  sensitive = true
}

