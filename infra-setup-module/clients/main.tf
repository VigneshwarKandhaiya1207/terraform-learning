terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}



module "app_vpc" {
  client_name = var.client_name
  Env         = var.Env
  application = var.application
  source      = "../modules/vpc"

  cidr_block = var.cidr_block
  subnets    = var.subnets
}



module "map_alb" {
  source            = "../modules/alb"
  client_name       = var.client_name
  Env               = var.Env
  application       = var.application
  create            = var.enable_map
  name_prefix       = "${var.client_name}-${local.common_tags.Env}-${var.application}-admin"
  vpc_id            = module.app_vpc.vpc_id
  public_subnet_ids = [for s in module.app_vpc.public_subnets : s.id]
}


module "cwb_alb" {
  source            = "../modules/alb"
  client_name       = var.client_name
  Env               = var.Env
  application       = var.application
  create            = var.enable_cwb
  name_prefix       = "${var.client_name}-${local.common_tags.Env}-${var.application}-cwb"
  vpc_id            = module.app_vpc.vpc_id
  public_subnet_ids = [for s in module.app_vpc.public_subnets : s.id]
}

# ---------------------------
# MDM EC2 (Admin + MySQL)
# ---------------------------
module "map_ec2" {
  source             = "../modules/ec2"
  client_name        = var.client_name
  Env                = var.Env
  application        = var.application
  create             = var.enable_map
  name_prefix        = "${var.client_name}-${local.common_tags.Env}-${var.application}"
  vpc_id             = module.app_vpc.vpc_id
  subnet_id          = values(module.app_vpc.private_subnets)[0].id
  alb_sg_id          = module.map_alb.alb_sg_id
  target_group_arn   = module.map_alb.target_group_arn
  ami_id             = data.aws_ami.ubuntu.id
  key_name           = var.ssh_key_name
  module_application = "map"
}

module "cwb_ec2" {
  source             = "../modules/ec2"
  client_name        = var.client_name
  Env                = var.Env
  application        = var.application
  create             = var.enable_cwb
  name_prefix        = "${var.client_name}-${local.common_tags.Env}-${var.application}"
  vpc_id             = module.app_vpc.vpc_id
  subnet_id          = values(module.app_vpc.private_subnets)[0].id
  alb_sg_id          = module.cwb_alb.alb_sg_id
  target_group_arn   = module.cwb_alb.target_group_arn
  ami_id             = data.aws_ami.ubuntu.id
  key_name           = var.ssh_key_name
  module_application = "cwb"
}


locals {
  all_vpcs = {
    vpc1 = module.app_vpc.vpc_info
  }
}

# CLI Output
output "infra_summary_text" {
  description = "Consolidated infra summary for all VPCs"
  value       = templatefile("${path.module}/templates/infra-summary.tmpl", { vpcs = local.all_vpcs })
}

# Optional: write to a file
resource "local_file" "infra_summary_file" {
  content  = templatefile("${path.module}/templates/infra-summary.tmpl", { vpcs = local.all_vpcs })
  filename = "${path.module}/${var.client_name}-${local.common_tags.Env}-${var.application}-infra-summary.txt"

}
