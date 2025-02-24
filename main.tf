# vpc-subnet-nat

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = "dev-hcp-0"
      Cluster     = var.cluster_name
      Customer    = "developers"
      Project     = "test"
      rosa_cluster =  var.cluster_name
    }
  }
}

#
# vpc
#
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = "true"

  tags = merge(
    var.common_tags,
    {
      #Name = "${var.cluster_name}"
      Name = "rosa-vpc"
    },
  )
  lifecycle {
    ignore_changes = [tags]
  }
  #tags = {
  #  Name = "${var.cluster_name}"
  #}
}

#
# subnets
#
resource "aws_subnet" "rosa_public_subnets" {
  for_each = var.rosa_public_subnet

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = merge(
    var.common_tags,
    {
      Name                     = join("-", ["rosa-public-subnet", split("-", each.key)[2]])
      vpc_id                   = "${aws_vpc.vpc.id}"
      "kubernetes.io/role/elb" = 1
      subnet_type              = "public"
    },
  )
  lifecycle {
    ignore_changes = [tags]
  }

}

resource "aws_subnet" "rosa_private_subnets" {
  for_each = var.rosa_private_subnet

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = merge(
    var.common_tags,
    {
      Name                              = join("-", ["rosa-private-subnet", split("-", each.key)[2]])
      vpc_id                            = "${aws_vpc.vpc.id}"
      "kubernetes.io/role/internal-elb" = 1
      subnet_type                       = "private"
    },
  )
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "time_sleep" "subnets_public" {
  create_duration = "30s"
  depends_on      = [aws_subnet.rosa_public_subnets]
}

resource "time_sleep" "subnets_private" {
  create_duration = "30s"
  depends_on      = [aws_subnet.rosa_private_subnets]
}

#
# igw
#
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name   = "igw-${var.cluster_name}"
    vpc_id = "${aws_vpc.vpc.id}"
  }

  depends_on = [aws_vpc.vpc]
}

#
# public, route_table, route_table_association
#
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  #route {
  #  ipv6_cidr_block        = "::/0"
  #  egress_only_gateway_id = aws_internet_gateway.gw.id
  #}

  tags = {
    Name   = "public-${var.cluster_name}"
    vpc_id = "${aws_vpc.vpc.id}"
  }

  depends_on = []
}


#resource "aws_route" "ipv6_egress_route" {
#  count                       = length(var.rosa_public_subnet)

#  route_table_id              = aws_route_table.public_route.id
#  destination_ipv6_cidr_block = "::/0"
#  gateway_id                  = aws_internet_gateway.gw.id

#  depends_on                  = [aws_route_table.public_route]
#}

resource "aws_route_table_association" "public_route_table_association" {
  for_each = aws_subnet.rosa_public_subnets

  route_table_id = aws_route_table.public_route.id
  subnet_id      = each.value.id

  depends_on = [aws_route_table.public_route]
}

#
# private, route_table, route, route_table_association
#

resource "aws_route_table" "private_route" {
  count = length(var.rosa_private_subnet)

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name   = "private-${var.cluster_name}-${count.index}"
    vpc_id = "${aws_vpc.vpc.id}"
  }
  depends_on = []
}

resource "aws_route" "private_nat" {
  count = length(var.rosa_private_subnet)

  route_table_id         = aws_route_table.private_route[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id

  depends_on = [aws_route_table.private_route]
}

resource "aws_route_table_association" "private_route_table_association" {
  count = length(var.rosa_private_subnet)

  subnet_id      = data.aws_subnets.rosa_private_subnets.ids[count.index]
  route_table_id = aws_route_table.private_route[count.index].id

  depends_on = [aws_route_table.private_route]
}

#
# eip
#

resource "aws_eip" "nat" {
  count = length(var.rosa_public_subnet)

  domain = "vpc"

  tags = {
    vpc_id = "${aws_vpc.vpc.id}"
  }
}

resource "time_sleep" "eips" {
  create_duration = "60s"
  depends_on      = [aws_eip.nat]
}

#
# nat_gateway
#

resource "aws_nat_gateway" "main" {
  count = length(var.rosa_public_subnet)

  subnet_id     = data.aws_subnets.rosa_public_subnets.ids[count.index]
  allocation_id = data.aws_eips.eips.allocation_ids[count.index]

  tags = {
    Name   = "rosa-nat-instance-${count.index}"
    vpc_id = "${aws_vpc.vpc.id}"
  }

  depends_on = [aws_eip.nat]
}

#
# security groups ssh
#
resource "aws_security_group" "ssh" {
  name = "allow_ssh"
  description = "allow sshd traffic on port 22"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "ingress_ssh" {
  security_group_id = aws_security_group.ssh.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "egress_ssh" {
  security_group_id = aws_security_group.ssh.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}



#
# source data
#

data "aws_subnets" "rosa_public_subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc.id]
  }
  tags = {
    Name = "rosa-public-subnet*"
  }
  depends_on = [aws_subnet.rosa_public_subnets]
}

data "aws_subnets" "rosa_private_subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc.id]
  }
  tags = {
    Name = "rosa-private-subnet*"
  }
  depends_on = [aws_subnet.rosa_private_subnets]
}

data "aws_eips" "eips" {
  tags = {
    vpc_id = "${aws_vpc.vpc.id}"
  }
  depends_on = [aws_eip.nat]
}

data "aws_availability_zones" "availability_zones" {
  state = "available"
}

data "aws_nat_gateways" "ngws" {
  vpc_id = aws_vpc.vpc.id

  filter {
    name   = "state"
    values = ["available"]
  }
  depends_on = [aws_nat_gateway.main]
}

