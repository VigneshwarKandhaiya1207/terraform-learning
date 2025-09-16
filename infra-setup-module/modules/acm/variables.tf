variable "create" {
  type    = bool
  default = true
}

variable "client_name" {
  description = "Name prefix for VPC resources (unique per VPC)"
  type        = string
}

variable "Env" {
  description = "Name of the Environment"
  type        = string
}

variable "application" {
  description = "Name of the application"
  type        = string
}


variable "domain_name" {
  description = "Root domain (e.g. ihapps.ai)"
  type        = string
}

variable "subject_alternative_names" {
  description = "SANs (wildcards, subdomains)"
  type        = list(string)
  default     = []
}
