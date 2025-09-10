module "client_network" {
  source = "../module/network"

  vpc_configs = var.vpc_configs
}