variable "vpc_config" {
  type = object({
    cidr_block = string
  })
}

variable "subnet_config" {
  type = map(object({
    cidr_block = string
    az         = string
    public     = optional(bool, false)
  }))
}