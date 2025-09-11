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
  name   = var.name
  source = "../modules/vpc"

  cidr_block = var.cidr_block
  subnets    = var.subnets
}