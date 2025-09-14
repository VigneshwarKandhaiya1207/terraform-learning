locals {
  common_tags = {
    BSN         = "${var.client_name}"
    Env         = "${var.Env}"
    Cost-Center = "${var.client_name}-${var.Env}"
  }
}

# ---------------------------
# Security Group for ALB
# ---------------------------
resource "aws_security_group" "alb_sg" {
  count       = var.create ? 1 : 0
  name        = "${var.name_prefix}-alb-sg"
  description = "Security group for ${var.name_prefix} ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS will be added later once ACM is ready
  # ingress {
  #   description = "Allow HTTPS"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags,
  { Name = "${var.name_prefix}-sg" })
}

# ---------------------------
# Load Balancer
# ---------------------------
resource "aws_lb" "this" {
  count              = var.create ? 1 : 0
  name               = replace(var.name_prefix, "/", "-")
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.alb_sg[0].id]

  tags = merge(local.common_tags,
  { Name = "${var.name_prefix}-alb" })
}

# ---------------------------
# Target Group
# ---------------------------
resource "aws_lb_target_group" "this" {
  count    = var.create ? 1 : 0
  name     = "${var.name_prefix}-tg"
  port     = var.port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = var.health_check_path
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = merge(local.common_tags,
  { Name = "${var.name_prefix}-tg" })
}

# ---------------------------
# HTTP Listener (forward to TG)
# ---------------------------
resource "aws_lb_listener" "http_forward" {
  count             = var.create ? 1 : 0
  load_balancer_arn = aws_lb.this[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }
}


