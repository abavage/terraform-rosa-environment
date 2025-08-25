resource "aws_key_pair" "ssh_key" {
  key_name   = "one"
  public_key = file("~/.ssh/one_id_rsa.pub")
}

# Changed to use parameter store
data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.7.2025*-x86_64"]
  }
}

output "ami_id" {
  value = data.aws_ami.amazon-linux.id
}

data "aws_ami" "centos" {
  most_recent = true
  owners      = ["125523088429"] # CentOS official account

  filter {
    name   = "name"
    values = ["CentOS Stream 9 x86_64 2025*"]
  }
}

output "centos_ami_id" {
  value = data.aws_ami.centos.id
}




data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

output "param_id" {
  value = nonsensitive(data.aws_ssm_parameter.al2023.value)
  #sensitive = true
}

#
# security groups
#

resource "aws_security_group" "common" {
  name        = "ec2_common"
  description = "common ingress port to ec2 hosts"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name         = "ec2_common"
  }


}

resource "aws_vpc_security_group_ingress_rule" "ingress_rules" {
  for_each          = var.ec2_sg_rules

  security_group_id = aws_security_group.common.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_ipv4         = each.value.cidr_ipv4
  ip_protocol       = each.value.ip_protocol
}


resource "aws_vpc_security_group_egress_rule" "egress_rules" {
  for_each          = var.ec2_sg_rules

  security_group_id = aws_security_group.common.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_ipv4         = each.value.cidr_ipv4
  ip_protocol       = each.value.ip_protocol

}

resource "aws_instance" "vm" {
  ami           = data.aws_ami.centos.id
  #ami           = data.aws_ssm_parameter.al2023.value
  subnet_id      = tolist(data.aws_subnets.rosa_public_subnets.ids)[0]
  vpc_security_group_ids = [aws_security_group.common.id]
  instance_type = "t3.micro"
  key_name        = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  root_block_device {
    volume_size = "15"
  }
  metadata_options {
    http_tokens = "optional"
    http_endpoint = "enabled"
  }
  count = 1
  tags = {
    Name = "one"
    another_tag = "tf-node"
    blah        = "jjj"
    this        = "that"
  }
  user_data = file("doit.sh")
  user_data_replace_on_change = true

  lifecycle {
    ignore_changes = [tags]
  }
}
