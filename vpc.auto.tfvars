# public = true

create_vpce_private_rosa_cluster = false

aws_region = "ap-southeast-2"

vpc_cidr = "10.0.0.0/16"

aws_subnet_public = {
  "ap-southeast-2a" : "10.0.2.0/23",
  "ap-southeast-2b" : "10.0.4.0/23",
  "ap-southeast-2c" : "10.0.6.0/23"
}

aws_subnet_private = {
  "ap-southeast-2a" : "10.0.8.0/23",
  "ap-southeast-2b" : "10.0.10.0/23",
  "ap-southeast-2c" : "10.0.12.0/23"
}


tags = {
  "clusterType" : "ROSA_Public"
  "env" : "nonprod"
}

ec2_bastion_public_source_subnet = false # linux instance into a pubic subnet
ec2_linux_bastion_name           = "centos9"
linux_instance_count             = 1
ec2_windows_bastion_name         = "windows25"
deploy_windows_instance          = true


common_ec2_sg_rules = {
  "ssh" = {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_ipv4   = "0.0.0.0/0"
    ip_protocol = "tcp"
  }
  "http" = {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_ipv4   = "0.0.0.0/0"
    ip_protocol = "tcp"
  }
  "https" = {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_ipv4   = "0.0.0.0/0"
    ip_protocol = "tcp"
  }
  "squid" = {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_ipv4   = "0.0.0.0/0"
    ip_protocol = "tcp"
  }
}


