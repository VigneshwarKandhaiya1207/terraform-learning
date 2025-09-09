variable "ec2_instance_type" {
  type    = string

  validation {
    condition = contains(["t2.micro"],var.ec2_instance_type)
    error_message = "Only t2.micro instance type is allowed."
  }
  
}

variable "ec2_volume_config" {
  type = object({
    size = number
    type = string
  })

  description = "The size and type of the root block volume for ec2 instance"

  default = {
    size = 10
    type = "gp3"
  }

}

variable "additional_tags" {
  type = map(string)

}