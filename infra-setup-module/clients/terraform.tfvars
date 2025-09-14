client_name = "testing"
Env         = "dev"
cidr_block  = "10.0.0.0/16"
region      = "us-east-1"
application = "APP"
enable_map  = true
enable_cwb  = false
ssh_key_name = "cwb.pem"


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