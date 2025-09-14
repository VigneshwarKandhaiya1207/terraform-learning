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

variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "port" {
  type    = number
  default = 80
}

variable "health_check_path" {
  type    = string
  default = "/"
}
