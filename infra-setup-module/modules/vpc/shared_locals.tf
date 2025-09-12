locals {
  common_tags ={
    BSN = "${var.client_name}"
    Env = "${var.Env}"
    Cost-Center = "${var.client_name}-${var.Env}"
  }
}