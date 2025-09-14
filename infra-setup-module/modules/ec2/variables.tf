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

variable "subnet_id" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group to attach EC2"
  type        = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = null
}

variable "module_application" {
  description = "Application Module"
  type        = string
}