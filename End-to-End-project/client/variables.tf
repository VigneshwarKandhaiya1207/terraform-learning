variable "cidr_block" {
  type = string
}

variable "subnet_config" {
  type = map(object({
    cidr_block = string
    az         = string
    public     = optional(bool, false)
  }))

}