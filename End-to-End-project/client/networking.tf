module "module_network" {
  source = "../module/network"

  vpc_config = {
    cidr_block = var.cidr_block
  }

  subnet_config = var.subnet_config
}


