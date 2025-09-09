ec2_instance_count = 0
subnet_count       = 2
ec2_instance_type  = "t2.micro"
ec2_instance_config_list = [{
  instance_type = "t2.micro"
  ami           = "ubuntu"
  }, {
  instance_type = "t2.micro"
  ami           = "nginx"
}]

subnet_config = {
  default = {
    cidr_block = "10.0.0.0/24"
  },

  subnet_1 = {
    cidr_block = "10.0.1.0/24"
  }
}

ec2_instance_config_map = {
  ubuntu_1 = {
    instance_type = "t2.micro"
    ami = "ubuntu"
  },
  nginx_1 = {
    instance_type = "t2.micro"
    ami = "nginx"
    subnet_name="subnet_1"
  }
}