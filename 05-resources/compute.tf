resource "aws_instance" "web" {
  ami                         = "ami-08b00e6f894a62af3"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.public_http_traffic.id]

  root_block_device {
    delete_on_termination = true
    volume_size           = 10
    volume_type           = "gp3"
  }


  tags = merge(local.common_tags, {
    Name       = "05-resources-web"
    Costcenter = "vignesh-testing"
  })

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group" "public_http_traffic" {
  vpc_id      = aws_vpc.main.id
  description = "Security group that allows ingress http and https traffic"
  name        = "public_http_traffic"

  tags = merge(local.common_tags, {
    Name = "05-resources-public-security"
  })

}


resource "aws_vpc_security_group_ingress_rule" "http_traffic" {
  security_group_id = aws_security_group.public_http_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "https_traffic" {
  security_group_id = aws_security_group.public_http_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

}
