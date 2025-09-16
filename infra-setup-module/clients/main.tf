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
  source      = "../modules/vpc"
  client_name = var.client_name
  Env         = var.Env
  application = var.application
  cidr_block  = var.cidr_block
  subnets     = var.subnets
}

module "acm" {
  source                    = "../modules/acm"
  client_name               = var.client_name
  Env                       = var.Env
  application               = var.application
  create                    = true
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
}


# ---------------------------
# MAP ALB (Admin + MySQL)
# ---------------------------
module "map_alb" {
  source            = "../modules/alb"
  client_name       = var.client_name
  Env               = var.Env
  application       = var.application
  create            = var.enable_map
  name_prefix       = "${var.client_name}-${var.Env}-map"
  vpc_id            = module.app_vpc.vpc_id
  public_subnet_ids = [for s in module.app_vpc.public_subnets : s.id]
  acm_certificate_arn = module.acm.certificate_arn
}

# ---------------------------
# IDQ ALB
# ---------------------------
module "cwb_alb" {
  source            = "../modules/alb"
  client_name       = var.client_name
  Env               = var.Env
  application       = var.application
  create            = var.enable_cwb
  name_prefix       = "${var.client_name}-${var.Env}-cwb"
  vpc_id            = module.app_vpc.vpc_id
  public_subnet_ids = [for s in module.app_vpc.public_subnets : s.id]
  acm_certificate_arn = module.acm.certificate_arn
}


# ---------------------------
# MAP EC2 (Admin + MySQL)
# ---------------------------
module "map_ec2" {
  source             = "../modules/ec2"
  client_name        = var.client_name
  Env                = var.Env
  application        = var.application
  create             = var.enable_map
  name_prefix        = "${var.client_name}-${var.Env}-map"
  vpc_id             = module.app_vpc.vpc_id
  subnet_id          = values(module.app_vpc.private_subnets)[0].id
  alb_sg_id          = try(module.map_alb.alb_sg_id, null)
  target_group_arn   = try(module.map_alb.target_group_arn, null)
  ami_id             = data.aws_ami.ubuntu.id
  key_name           = var.ssh_key_name
  module_application = "map"
}



# ---------------------------
# CWB EC2
# ---------------------------
module "cwb_ec2" {
  source             = "../modules/ec2"
  client_name        = var.client_name
  Env                = var.Env
  application        = var.application
  create             = var.enable_cwb
  name_prefix        = "${var.client_name}-${var.Env}-cwb"
  vpc_id             = module.app_vpc.vpc_id
  subnet_id          = values(module.app_vpc.private_subnets)[0].id
  alb_sg_id          = try(module.cwb_alb.alb_sg_id, null)
  target_group_arn   = try(module.cwb_alb.target_group_arn, null)
  ami_id             = data.aws_ami.ubuntu.id
  key_name           = var.ssh_key_name
  module_application = "cwb"
}


# ---------------------------
# CloudFront (MAP only)
# ---------------------------
module "map_cloudfront" {
  source              = "../modules/cloudfront"
  client_name         = var.client_name
  Env                 = var.Env
  application         = var.application
  create              = var.enable_map
  name_prefix         = "${var.client_name}-${var.Env}-map"
  s3_bucket_name      = var.s3_bucket_name
  acm_certificate_arn = module.acm.certificate_arn
  aliases             = var.subject_alternative_names
}





# locals {
#   all_vpcs = {
#     vpc1 = module.app_vpc.vpc_info
#   }
# }


locals {
  infra_summary = {
    vpc = {
      vpc1 = module.app_vpc.vpc_info
    }
    acm = {
      certificate_arn = module.acm.certificate_arn
    }
    alb = {
      map = {
        dns_name = module.map_alb.alb_dns_name
      }
      cwb = {
        dns_name = module.cwb_alb.alb_dns_name
      }
    }
    ec2 = {
      map = {
        app_instance   = try(module.map_ec2.app_instance_id, null)
        mysql_instance = try(module.map_ec2.mysql_instance_id, null)
      }
      cwb = {
        app_instance = try(module.cwb_ec2.app_instance_id, null)
      }
    }
    cloudfront = {
      map = {
        distribution_id = try(module.map_cloudfront.cloudfront_distribution_id, null)
        domain_name     = try(module.map_cloudfront.cloudfront_domain_name, null)
      }
    }
  }
}


output "infra_summary_text" {
  description = "Consolidated infra summary"
  value       = templatefile("${path.module}/templates/infra-summary.tmpl", { infra = local.infra_summary })
}

resource "local_file" "infra_summary_file" {
  content  = templatefile("${path.module}/templates/infra-summary.tmpl", { infra = local.infra_summary })
  filename = "${path.module}/${var.client_name}-${var.Env}-${var.application}-infra-summary.txt"
}


# # CLI Output
# output "infra_summary_text" {
#   description = "Consolidated infra summary for all VPCs"
#   value       = templatefile("${path.module}/templates/infra-summary.tmpl", { vpcs = local.all_vpcs })
# }

# # Optional: write to a file
# resource "local_file" "infra_summary_file" {
#   content  = templatefile("${path.module}/templates/infra-summary.tmpl", { vpcs = local.all_vpcs })
#   filename = "${path.module}/${var.client_name}-${local.common_tags.Env}-${var.application}-infra-summary.txt"

# }
