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

module "app_vpc" {
  client_name   = var.client_name
  Env = var.Env
  application = var.application
  source = "../modules/vpc"

  cidr_block = var.cidr_block
  subnets    = var.subnets
}


locals {
  all_vpcs = {
    vpc1            = module.app_vpc.vpc_info
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
