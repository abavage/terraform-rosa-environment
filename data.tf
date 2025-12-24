data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.main.id]
  }

  tags = {
    Name = "rosa-public-subnet*"
  }
  depends_on = [
    aws_subnet.aws_subnet_public
  ]
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.main.id]
  }

  tags = {
    Name = "rosa-private-subnet*"
  }
  depends_on = [
    aws_subnet.aws_subnet_private
  ]
}

data "aws_route_tables" "public" {
  vpc_id = aws_vpc.main.id

  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
  depends_on = [
    aws_route_table.default
  ]
}

data "aws_route_tables" "private" {
  vpc_id = aws_vpc.main.id

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
  depends_on = [
    aws_route_table.nat
  ]
}

data "aws_ami" "centos" {
  most_recent = true
  owners      = ["125523088429"] # CentOS official account

  filter {
    name   = "name"
    values = ["CentOS Stream 9 x86_64 2025*"]
  }
}

data "aws_ami" "windows" {
  most_recent = true
  owners      = ["801119661308"] # aws

  filter {
    name   = "name"
    values = ["Windows_Server-2025-English-Full-Base-2025*"]
  }
}