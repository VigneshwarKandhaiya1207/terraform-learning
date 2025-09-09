resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    project = local.project
    Name    = local.project
  }
}

resource "aws_subnet" "main_subnet" {
  for_each = var.subnet_config
  cidr_block = each.value.cidr_block
  vpc_id     = aws_vpc.main_vpc.id

  tags = {
    project = local.project
    Name    = "${local.project}-${each.key}"
  }
}
