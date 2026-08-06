variable "project" {
  type    = string
}

variable "environment" {
  type    = string
}

variable "region_short" {
  type    = string
}

variable "location" {
  type    = string
}

variable "resource_group_name" {
  type    = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vnet_cidr" {
  type        = string
  description = "Address space for the VNet"
  default     = "10.0.0.0/16"
}

variable "aks_subnet_cidr" {
  type        = string
  description = "Subnet for AKS nodes and pods"
  default     = "10.0.1.0/24"
}

variable "appgw_subnet_cidr" {
  type        = string
  description = "Subnet dedicated to Application Gateway"
  default     = "10.0.2.0/24"
}
