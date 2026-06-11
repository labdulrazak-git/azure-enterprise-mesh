variable "location" {
  type    = string
  default = "eastus"
}

variable "hub_prefix" {
  type    = string
  default = "rg-mesh-hub" # <-- Updated
}

variable "spoke_prefix" {
  type    = string
  default = "rg-mesh-spoke" # <-- Updated
}
