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
  for_each    = var.create ? { "alb" = var.vpc_id } : {}
  name        = "${var.name_prefix}-alb-sg"
  description = "Security group for ${var.name_prefix} ALB"
  vpc_id      = each.value

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------
# Load Balancer
# ---------------------------
resource "aws_lb" "this" {
  for_each           = var.create ? { "alb" = var.vpc_id } : {}
  name               = replace(var.name_prefix, "/", "-")
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.alb_sg["alb"].id]
}

# ---------------------------
# Target Group
# ---------------------------
resource "aws_lb_target_group" "this" {
  for_each = var.create ? { "tg" = var.vpc_id } : {}
  name     = "${var.name_prefix}-tg"
  port     = var.port
  protocol = "HTTP"
  vpc_id   = each.value

  health_check {
    path                = var.health_check_path
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

# HTTP Listener → redirect to HTTPS
resource "aws_lb_listener" "http_redirect" {
  for_each          = var.create ? { "http" = true } : {}
  load_balancer_arn = aws_lb.this["alb"].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener → forward to TG
resource "aws_lb_listener" "https_forward" {
  for_each = var.create ? { "https" = true } : {}

  load_balancer_arn = aws_lb.this["alb"].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this["tg"].arn
  }
}
