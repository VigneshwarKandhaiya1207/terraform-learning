variable "region" {
  type = string
}

variable "client_name" {
  description = "Name prefix for VPC resources (unique per VPC)"
  type        = string
}

variable "Env" {
  description = "Name of the environment"
  type = string
}

variable "application" {
  description = "Name of the application"
  type = string
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