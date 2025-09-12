client_name       = "terraform-testing"
Env = "dev"
cidr_block = "10.0.0.0/16"
region = "us-east-1"
application = "APP"

subnets = {
  "private_1" = {
    cidr_block = "10.0.0.0/24"
    az         = "us-east-1a"
    public     = false

  },

  "private_2" = {
    cidr_block = "10.0.1.0/24"
    az         = "us-east-1b"
    public     = false
  }

  "public_1" = {
    cidr_block = "10.0.2.0/24"
    az         = "us-east-1a"
    public     = true
  }

  "public_2" = {
    cidr_block = "10.0.3.0/24"
    az         = "us-east-1b"
    public     = true
    public     = true
  }
}