resource "aws_security_group" "common" {
  name        = "linux-ec2-common"
  description = "common ingress port to ec2 hosts"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "linux-ec2-common"
  }
  depends_on = [
    aws_vpc.main
  ]
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rules" {
  for_each = var.common_ec2_sg_rules

  security_group_id = aws_security_group.common.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_ipv4         = each.value.cidr_ipv4
  ip_protocol       = each.value.ip_protocol

  depends_on = [
    aws_security_group.common
  ]
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.common.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  depends_on = [
    aws_security_group.common
  ]
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "one"
  public_key = file("~/.ssh/one_id_rsa.pub")
}

resource "random_pet" "linux_instance_name" {
  for_each = toset([
    for i in range(var.linux_instance_count) : tostring(i)
  ])
}

resource "aws_instance" "ec2_linux" {
  for_each = random_pet.linux_instance_name

  ami                         = data.aws_ami.centos.id
  subnet_id                   = var.ec2_bastion_public_source_subnet ? tolist(data.aws_subnets.public_subnets.ids)[0] : tolist(data.aws_subnets.private_subnets.ids)[0]
  vpc_security_group_ids      = [aws_security_group.common.id]
  instance_type               = "t3.small"
  key_name                    = aws_key_pair.ssh_key.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_role.name
  associate_public_ip_address = var.ec2_bastion_public_source_subnet ? true : false
  root_block_device {
    volume_size = "15"
  }
  metadata_options {
    http_tokens   = "optional"
    http_endpoint = "enabled"
  }
  #count = 0
  tags = merge(
    var.tags,
    {
      #Name = "${var.ec2_linux_bastion_name}-${count.index}"
      #Name = "${var.ec2_linux_bastion_name}-${random_pet.linux_instance_name.id}"
      #Name = each.value.id
      Name = "${var.ec2_linux_bastion_name}-${each.value.id}"
    }
  )
  user_data                   = file("${path.module}/userdata/common.sh")
  user_data_replace_on_change = true

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  depends_on = [
    aws_route_table_association.public,
    aws_route_table_association.private
  ]
}