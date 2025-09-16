locals {
  common_tags = {
    BSN         = "${var.client_name}"
    Env         = "${var.Env}"
    Cost-Center = "${var.client_name}-${var.Env}"
  }
}

# ---------------------------
# Security Group for App EC2
# ---------------------------
resource "aws_security_group" "app_sg" {
  for_each    = var.create ? { "app" = var.vpc_id } : {}
  name        = "${var.name_prefix}-app-sg"
  description = "SG for ${var.module_application} App EC2"
  vpc_id      = each.value

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = var.alb_sg_id != null ? [var.alb_sg_id] : []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.name_prefix}-app-sg" })
}

# ---------------------------
# Security Group for MySQL (only for MAP)
# ---------------------------
resource "aws_security_group" "mysql_sg" {
  for_each    = (var.create && var.module_application == "map") ? { "mysql" = var.vpc_id } : {}
  name        = "${var.name_prefix}-mysql-sg"
  description = "SG for MySQL (MAP only)"
  vpc_id      = each.value

  ingress {
    description     = "Allow MySQL from Admin EC2 SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg["app"].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.name_prefix}-mysql-sg" })
}

# ---------------------------
# Admin / App EC2
# ---------------------------
resource "aws_instance" "app" {
  for_each              = var.create ? { "app" = var.subnet_id } : {}
  ami                   = var.ami_id
  instance_type         = var.instance_type
  subnet_id             = each.value
  key_name              = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg["app"].id]

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-${var.module_application}-admin"
  })
}

# ---------------------------
# MySQL EC2 (only for MAP)
# ---------------------------
resource "aws_instance" "mysql" {
  for_each              = (var.create && var.module_application == "map") ? { "mysql" = var.subnet_id } : {}
  ami                   = var.ami_id
  instance_type         = var.instance_type
  subnet_id             = each.value
  key_name              = var.key_name
  vpc_security_group_ids = [aws_security_group.mysql_sg["mysql"].id]

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-mysql"
  })
}

# ---------------------------
# Target Group Attachments
# ---------------------------
resource "aws_lb_target_group_attachment" "app_attachment" {
  for_each = var.create ? { "attach" = true } : {}

  target_group_arn = var.target_group_arn
  target_id        = aws_instance.app["app"].id
  port             = 80
}
