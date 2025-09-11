variable "name" {
  description = "Name prefix for VPC resources (unique per VPC)"
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

variable "enforce_private_requires_public" {
  description = "If true, fail when private subnets exist but no public subnet (so NAT cannot be placed)."
  type        = bool
  default     = true
}
