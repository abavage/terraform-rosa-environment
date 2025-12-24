### VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "rosa_public"
    }
  )

}

### Subnets 
resource "aws_subnet" "aws_subnet_public" {
  for_each = var.aws_subnet_public
  #for_each = var.public ? var.aws_subnet_public : {}

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(
    var.tags,
    {
      Name = join("-", ["rosa-public-subnet", split("-", each.key)[2]])
    }
  )
  depends_on = [
    aws_vpc.main
  ]
}

resource "aws_subnet" "aws_subnet_private" {
  for_each = var.aws_subnet_private

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(
    var.tags,
    {
      Name                              = join("-", ["rosa-private-subnet", split("-", each.key)[2]])
      "kubernetes.io/role/internal-elb" = ""
    }
  )
  depends_on = [
    aws_vpc.main
  ]
}

### Internet Gateway
resource "aws_internet_gateway" "gw" {
  #count = var.public ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
  depends_on = [
    aws_vpc.main
  ]
}

### Route table
resource "aws_route_table" "default" {
  #count = var.public ? 1 : 0

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "default-public"
  }
  depends_on = [
    aws_internet_gateway.gw
  ]
}

### Route table subnet association
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.aws_subnet_public
  #for_each = var.public ? aws_subnet.aws_subnet_public : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.default.id
  #route_table_id = try(aws_route_table.default[0].id, null)

  depends_on = [
    aws_route_table.default
  ]
}


### EIP
resource "aws_eip" "nat" {
  for_each = aws_subnet.aws_subnet_public
  #for_each = var.public ? aws_subnet.aws_subnet_public : {}

  domain = "vpc"

  tags = {
    Name = "nat-gateway-rosa-public-subnet"
  }

  depends_on = [
    aws_vpc.main
  ]
}

### NAT Gateway
resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.aws_subnet_public
  #for_each = var.public ? aws_subnet.aws_subnet_public : {}

  subnet_id     = each.value.id
  allocation_id = aws_eip.nat[each.key].id

  tags = merge(
    var.tags,
    {
      Name = join("-", ["rosa-public-subnet", split("-", each.key)[2]])
    }
  )

  depends_on = [
    aws_eip.nat,
    aws_route_table_association.public,
    aws_subnet.aws_subnet_public
  ]
}


### NAT Route table
resource "aws_route_table" "nat" {
  for_each = aws_subnet.aws_subnet_private
  #for_each = var.public ? aws_subnet.aws_subnet_private : {}

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[each.key].id
  }

  tags = {
    Name = join("-", ["rosa-nat-gateway-private", split("-", each.key)[2]])
  }
  depends_on = [
    aws_nat_gateway.nat
  ]
}

### NAT Route table subnet association
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.aws_subnet_private
  #for_each = var.public ? aws_subnet.aws_subnet_private : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.nat[each.key].id

  depends_on = [
    aws_route_table.nat
  ]
}

### VPCE s3
resource "aws_vpc_endpoint" "s3" {
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Gateway"

  # Associate with route tables instead of subnets
  route_table_ids = local.route_tables

  tags = {
    Name    = "s3"
    service = "ROSA"
  }
  depends_on = [
    aws_route_table.default,
    aws_route_table.nat
  ]
}


## SSM
resource "aws_vpc_endpoint" "ssm" {
  
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-southeast-2.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids         = values(aws_subnet.aws_subnet_private)[*].id
  security_group_ids = [aws_security_group.vpce.id]
  private_dns_enabled = true

  tags = {
    Name    = "ssm"
  }
  depends_on = [
    aws_vpc.main
  ]
}

resource "aws_vpc_endpoint" "ec2messages" {
  
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-southeast-2.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids         = values(aws_subnet.aws_subnet_private)[*].id
  security_group_ids = [aws_security_group.vpce.id]
  private_dns_enabled = true

  tags = {
    Name    = "ec2messages"
  }
  depends_on = [
    aws_vpc.main
  ]
}

resource "aws_vpc_endpoint" "ssmmessages" {
  
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-southeast-2.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids         = values(aws_subnet.aws_subnet_private)[*].id
  security_group_ids = [aws_security_group.vpce.id]
  private_dns_enabled = true

  tags = {
    Name    = "ssmmessages"
  }
  depends_on = [
    aws_vpc.main
  ]
}


resource "aws_security_group" "vpce" {
  name        = "vpce_common"
  description = "common 443 port for vpce"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "vpce_common"
  }
  depends_on = [
    aws_vpc.main
  ]
}

resource "aws_vpc_security_group_ingress_rule" "vpce_common_rules" {
  security_group_id = aws_security_group.vpce.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  depends_on = [
    aws_security_group.vpce
  ]
}

resource "aws_vpc_security_group_egress_rule" "vpce_allow_all" {
  security_group_id = aws_security_group.vpce.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  depends_on = [
    aws_security_group.vpce
  ]
}




########

resource "aws_security_group" "authorize_inbound_vpc_traffic" {
  vpc_id = aws_vpc.main.id
  name   = "private-cluster-vpce"
  description = "security grroup for private cluster vpce"

  tags = {
    service      = "ROSA"
    Name         = "private-cluster-vpce"
  }
   
}

# Ingress rules (one per subnet CIDR from the map)
resource "aws_vpc_security_group_ingress_rule" "allow_inbound_from_private_subnets" {
  for_each          = var.aws_subnet_private
  security_group_id = aws_security_group.authorize_inbound_vpc_traffic.id
  cidr_ipv4         = each.value   # map value is the CIDR block
  ip_protocol       = "-1"
  #from_port         = 0
  #to_port           = 0

  # Optional: keep track of which AZ created this rule
  description = "Allow from ${each.key}"

  tags = {
    service      = "ROSA"
    Name         = "private-cluster-vpce-ingress-${each.key}"
  }
  
}

# Egress rule (allow all outbound traffic)
resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  security_group_id = aws_security_group.authorize_inbound_vpc_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all traffic

  tags = {
    service      = "ROSA"
    Name         = "private-cluster-vpce-egress"
  }

}
