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
  count       = var.create ? 1 : 0
  name        = "${var.name_prefix}-sg"
  description = "SG for ${var.application} EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags,
  { Name = "${var.client_name}-${local.common_tags.Env}-${var.application}-ec2-sg" })

}

# ---------------------------
# Security Group for MySQL EC2 (only for MAP/ADMIN)
# ---------------------------
resource "aws_security_group" "mysql_sg" {
  count       = (var.create && var.module_application == "map") ? 1 : 0
  name        = "${var.name_prefix}-mysql-sg"
  description = "SG for MySQL EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow MySQL from Admin EC2 SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg[0].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags,
  { Name = "${var.client_name}-${local.common_tags.Env}-${var.application}-mysql-sg" })

}

# ---------------------------
#  EC2
# ---------------------------
resource "aws_instance" "app" {
  count                  = var.create ? 1 : 0
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg[0].id]

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-${var.module_application}"
  })
}

# ---------------------------
# MySQL EC2 (only for MAP/ADMIN)
# ---------------------------
resource "aws_instance" "mysql" {
  count                  = (var.create && var.module_application == "map") ? 1 : 0
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.mysql_sg[0].id]

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-mysql"
  })
}

# ---------------------------
# Target Group Attachments
# ---------------------------
resource "aws_lb_target_group_attachment" "app_attachment" {
  count            = var.create ? 1 : 0
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.app[0].id
  port             = 80
}
