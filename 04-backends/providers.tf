terraform {
  required_version = "> 1.7"
  backend "s3" {
    bucket       = "terraform-backend-configuration-vignesh"
    key          = "vignesh"
    region       = "us-east-1"
    use_lockfile = true

  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.3"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"

}
