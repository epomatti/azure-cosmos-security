variable "workload" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "random_suffix" {
  type = number
}

variable "keyvault_key_id" {
  type = string
}

variable "cosmos_identity_id" {
  type = string
}

variable "public_network_access_enabled" {
  type = bool
}
