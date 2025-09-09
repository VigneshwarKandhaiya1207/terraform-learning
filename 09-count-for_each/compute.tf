locals {
  ami_ids = {
    ubuntu = data.aws_ami.ubuntu.id
    nginx  = data.aws_ami.nginx.id
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

data "aws_ami" "nginx" {

  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-nginx-1.28.0-r03-linux-debian-12-x86_64-hvm-ebs-nami-f5774628-e459-457a-b058-3b513caefdee"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"]
}
# resource "aws_instance" "main" {
#     ami = data.aws_ami.ubuntu.id
#     count = var.ec2_instance_count
#     instance_type = var.ec2_instance_type
#     subnet_id = aws_subnet.main_subnet[count.index % length(aws_subnet.main_subnet)].id

#     tags = {
#       project = local.project
#       Name = "${local.project}-${count.index}"
#     }

# }

resource "aws_instance" "from_list" {
  ami           = local.ami_ids[var.ec2_instance_config_list[count.index].ami]
  count         = length(var.ec2_instance_config_list)
  subnet_id     = aws_subnet.main_subnet["default"].id
  instance_type = var.ec2_instance_config_list[count.index].instance_type

  tags = {
    project = local.project
    Name    = "${local.project}-${count.index}"
  }

}

resource "aws_instance" "from_map" {
  for_each = var.ec2_instance_config_map
  ami = local.ami_ids[each.value.ami]
  instance_type = each.value.instance_type
  subnet_id = aws_subnet.main_subnet[each.value.subnet_name].id

  tags = {
    project= local.project
    Name= "${local.project}-${each.key}"
  }
}

output "instance_id_from_list" {
  value = aws_instance.from_list[*].id
}

output "instance_id_from_map" {
  value = {
    for key,config in var.ec2_instance_config_map : key => aws_instance.from_map[key].id
  }
}