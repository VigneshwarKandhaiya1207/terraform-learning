variable "vpc_configs" {
  description = "The variable vpc configuration for the multiple VPC creation"
  type = map(object({
    vpc_config = object({
      cidr_block = string
    })

    subnet_config = map(object({
      cidr_block = string
      az         = string
      public     = optional(bool, false)
    }))
  }))

}