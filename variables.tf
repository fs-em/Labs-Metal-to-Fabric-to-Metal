variable "auth_token" {
  type        = string
  description = "Your Equinix Metal API key (https://console.equinix.com/users/-/api-keys)"
  sensitive   = true
}

variable "equinix_client_id" {
  type        = string
  description = "API Consumer Key available under 'My Apps' in developer portal. This argument can also be specified with the EQUINIX_API_CLIENTID shell environment variable."
  sensitive   = true
}

variable "equinix_client_secret" {
  type        = string
  description = "API Consumer secret available under 'My Apps' in developer portal. This argument can also be specified with the EQUINIX_API_CLIENTSECRET shell environment variable."
  sensitive   = true
}

variable "metal_project_id" {
  type        = string
  description = "Your Equinix Metal project ID, where you want to deploy your nodes to"
}

variable "plan" {
  type        = string
  description = "Metal server type you plan to deploy"
  default     = "m3.small.x86"
}

variable "operating_system" {
  type        = string
  description = "OS you want to deploy"
  default     = "ubuntu_20_04"
}


variable "metro1" {
  type        = string
  description = "Metal's Metro location you want to deploy your servers to"
  default     = "da"
}

variable "metro2" {
  type        = string
  description = "Metal's Metro location you want to deploy your servers to"
  default     = "dc"
}

variable "vxlan" {
  type        = string
  description = "vlan number for hosts"
  default     = "1040"
}

variable "conn_id" {
  type        = string
  description = "Metal's connection ID in metal's portal"
  default     = "go to metal portal and retrieve"
}

variable "aside_port" {
  type        = string
  description = "Metal's dedicated port ID in fabric portal"
  default     = "go to fabric portal and retrieve"
}


