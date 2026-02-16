variable "project_id" { type = string }
variable "name"       { type = string }
variable "location"   { type = string } # region, e.g. "us-central1"

variable "network" {
  type        = string
  description = "VPC network (name or self_link)."
}

variable "subnetwork" {
  type        = string
  description = "Subnetwork (name or self_link)."
}

variable "pods_secondary_range_name" {
  type        = string
  description = "Secondary range name for pods (from the subnet)."
}

variable "services_secondary_range_name" {
  type        = string
  description = "Secondary range name for services (from the subnet)."
}

variable "release_channel" {
  type        = string
  default     = "REGULAR"
  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel must be RAPID, REGULAR, or STABLE."
  }
}

variable "enable_private_cluster" {
  type    = bool
  default = true
}

variable "enable_private_endpoint" {
  type    = bool
  default = false
}

variable "master_ipv4_cidr_block" {
  type        = string
  default     = "172.16.0.0/28"
  description = "CIDR block for the private control plane endpoint."
}

variable "master_authorized_networks" {
  type = list(object({
    name = string
    cidr = string
  }))
  default = []
}

variable "enable_intranode_visibility" {
  type    = bool
  default = false
}

variable "enable_shielded_nodes" {
  type    = bool
  default = true
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "create_node_service_account" {
  type    = bool
  default = true
}

variable "node_service_account_email" {
  type        = string
  default     = null
  description = "If create_node_service_account=false, provide an existing SA email."
}

variable "node_pools" {
  description = "Map of node pools"
  type = map(object({
    name          = string
    node_count    = number
    min_node_count = number
    max_node_count = number
    machine_type  = string
    disk_size_gb  = number
    labels        = optional(map(string), {})
    tags          = optional(list(string), [])
  }))
}

variable "maintenance_start_time" {
  type        = string
  default     = null
  description = "RFC3339 start time for maintenance window"
}

variable "maintenance_end_time" {
  type        = string
  default     = null
  description = "RFC3339 end time for maintenance window"
}

variable "maintenance_recurrence" {
  type        = string
  default     = null
  description = "RRULE format recurrence (e.g. FREQ=WEEKLY;BYDAY=SU)"
}
