variable "project" {
  type    = string
  default = "cgx-nifi"
}

variable "environment" {
  type    = string
  default = "poc"
}

variable "location" {
  type        = string
  description = "Azure region (e.g. francecentral)"
}

variable "region_short" {
  type        = string
  description = "Short region label used in naming (e.g. fr, cn)"
}
