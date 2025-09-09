locals {
  project       = "07-terraform-variables-locals-objects"
  project_owner = "terraform-course"
  costCenter    = "1234"
}

locals {
  common_tags = {
    project       = local.project
    project_owner = local.project_owner
    costCenter    = local.costCenter
  }
}