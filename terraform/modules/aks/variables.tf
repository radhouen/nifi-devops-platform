variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "region_short" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "aks_subnet_id" {
  type        = string
  description = "Subnet ID where AKS nodes will be placed"
}

variable "k8s_version" {
  type    = string
  default = "1.29"
}

variable "system_node_count" {
  type    = number
  default = 1
}

variable "system_node_vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "nifi_node_count" {
  type    = number
  default = 1
}

variable "nifi_node_vm_size" {
  type    = string
  default = "Standard_B2ms"
}
