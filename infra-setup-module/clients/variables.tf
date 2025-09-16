
variable "region" {
  type = string
}

variable "client_name" {
  description = "Name prefix for VPC resources (unique per VPC)"
  type        = string
}

variable "Env" {
  description = "Name of the environment"
  type        = string
}

variable "application" {
  description = "Name of the application"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnets" {
  description = "Map of subnet definitions. key => { cidr_block, az, public = optional(bool,false) }"
  type = map(object({
    cidr_block = string
    az         = string
    public     = optional(bool, false)
  }))
}


# ---------------------------
# Application Toggles
# ---------------------------
variable "enable_map" {
  description = "Enable map application components"
  type        = bool
  default     = false
}

variable "enable_cwb" {
  description = "Enable cwb application components"
  type        = bool
  default     = false
}


variable "ssh_key_name" {
  description = "SSH key name (created via deploy.sh)"
  type        = string
}

# variable "map_ami" {
#   description = "AMI ID for map EC2s"
#   type        = string
# }

# variable "cwb_ami" {
#   description = "AMI ID for cwb EC2s"
#   type        = string
# }

variable "module_application" {
  description = "Application Module"
  type        = string
  default     = "map"
}

variable "domain_name" {
  description = "Root domain (e.g. ihapps.ai)"
  type        = string
}

variable "subject_alternative_names" {
  description = "SANs for ACM cert"
  type        = list(string)
  default     = []
}

variable "s3_bucket_name" {
  description = "Name of the Static website bucket name"
  type        = string
}
