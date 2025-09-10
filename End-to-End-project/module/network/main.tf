locals {
  # Flatten all subnets across VPCs
  all_subnets = merge([
    for vpc_key, vpc_cfg in var.vpc_configs : {
      for subnet_key, subnet_cfg in vpc_cfg.subnet_config :
      "${vpc_key}-${subnet_key}" => merge(subnet_cfg, {
        vpc_key    = vpc_key
        subnet_key = subnet_key
      })
    }
  ]...)

  # Public subnets (from all VPCs)
  public_subnets = {
    for key, cfg in local.all_subnets : key => cfg if lookup(cfg, "public", false)
  }

  # Private subnets (from all VPCs)
  private_subnets = {
    for key, cfg in local.all_subnets : key => cfg if !lookup(cfg, "public", false)
  }
}