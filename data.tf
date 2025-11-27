data "aws_vpc" "get_rosa_vpc" {
  filter {
    name = "tag:Name"
    values = ["rosa-vpc"]
  }
  depends_on = [
    aws_subnet.rosa_public_subnets
  ]
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.get_rosa_vpc.id]
    #values = [aws_vpc.vpc.id]
  }

  tags = {
    Name = "rosa-private-subnet*"
  }
  depends_on = [
    aws_subnet.rosa_private_subnets
  ]
}

data "aws_route_tables" "private" {
  #vpc_id = aws_vpc.vpc.id
  vpc_id = data.aws_vpc.get_rosa_vpc.id
  filter {
    name   = "tag:Name"
    values = ["*private*"] # adjust to match your naming convention
  }
  depends_on = [
    aws_route_table.private_route
  ]
}

data "aws_route_tables" "public" {
  #vpc_id = aws_vpc.vpc.id
  vpc_id = data.aws_vpc.get_rosa_vpc.id
  filter {
    name   = "tag:Name"
    values = ["*public*"] # adjust to match your naming convention
  }
  depends_on = [
    aws_route_table.public_route
  ]
}
