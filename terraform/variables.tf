variable "project" {
  type    = string
  default = "cgx-nifi"
}

variable "environment" {
  type    = string
  default = "poc"
}

variable "location" {
  type    = string
  default = "francecentral"
}

variable "region_short" {
  type    = string
  default = "fr"
}

variable "vnet_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "aks_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "appgw_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "k8s_version" {
  type    = string
  default = "1.29"
}

variable "system_node_vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "nifi_node_vm_size" {
  type    = string
  default = "Standard_B2ms"
}
