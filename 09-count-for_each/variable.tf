variable "subnet_count" {
  type = number
}

variable "ec2_instance_count" {
  type = number
}

variable "ec2_instance_type" {
  type = string
}

variable "ec2_instance_config_list" {
  type = list(object({
    instance_type = string
    ami           = string
    subnet_name= optional(string, "default")
  }))

  validation {
    condition     = alltrue([for config in var.ec2_instance_config_list : contains(["t2.micro", "t3.micro"], config.instance_type)])
    error_message = "Only t2.micro is allowed."
  }

  validation {
    condition     = alltrue([for config in var.ec2_instance_config_list : contains(["ubuntu", "nginx"], config.ami)])
    error_message = "Atleast one of the Provided \"ami\" values are not supported.\nAllowed values are \"ubuntu\" , \"nginx\""
  }
}

variable "ec2_instance_config_map" {
  type = map(object({
    instance_type= string
    ami = string
    subnet_name= optional(string, "default")
  }))
  
}

variable "subnet_config" {
  type = map(object({
    cidr_block = string
  }))
  
}