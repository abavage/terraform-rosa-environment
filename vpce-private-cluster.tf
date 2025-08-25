resource "aws_security_group" "authorize_inbound_vpc_traffic" {
  vpc_id = data.aws_vpc.get_rosa_vpc.id
  name   = "vpce-sg"

  tags = {
    Terraform    = "true"
    service      = "ROSA"
    cluster_name = var.cluster_name
    Name         = "vpce-sg"
  }
  
}

resource "aws_vpc_security_group_ingress_rule" "allow_ingress" {
  security_group_id = aws_security_group.authorize_inbound_vpc_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_egress" {
  security_group_id = aws_security_group.authorize_inbound_vpc_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_vpc_endpoint" "sts" {
  service_name      = "com.amazonaws.${var.aws_region}.sts"
  vpc_id            = data.aws_vpc.get_rosa_vpc.id
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  subnet_ids          = data.aws_subnets.private_subnets.ids
  security_group_ids  = [aws_security_group.authorize_inbound_vpc_traffic.id]

  tags = {
    Terraform    = "true"
    service      = "ROSA"
    cluster_name = var.cluster_name
    Name         = "sts"
  }
}


resource "aws_vpc_endpoint" "ecr_api" {
  service_name      = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_id            = data.aws_vpc.get_rosa_vpc.id
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  subnet_ids          = data.aws_subnets.private_subnets.ids
  security_group_ids  = [aws_security_group.authorize_inbound_vpc_traffic.id]

  tags = {
    Terraform    = "true"
    service      = "ROSA"
    cluster_name = var.cluster_name
    Name         = "ecr_api"
  }
}

# https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html
resource "aws_vpc_endpoint" "ecr_dkr" {
  service_name      = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_id            = data.aws_vpc.get_rosa_vpc.id
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  subnet_ids          = data.aws_subnets.private_subnets.ids
  security_group_ids  = [aws_security_group.authorize_inbound_vpc_traffic.id]

  tags = {
    Terraform    = "true"
    service      = "ROSA"
    cluster_name = var.cluster_name
    Name         = "ecr_dkr"
  }
}

# https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints-s3.html
resource "aws_vpc_endpoint" "s3" {
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = "Gateway"

  # Associate with route tables instead of subnets
  route_table_ids = data.aws_route_tables.private.ids
  

  tags = {
    Terraform    = "true"
    service      = "ROSA"
    cluster_name = var.cluster_name
    Name         = "s3"
  }
}