resource "aws_vpc_endpoint" "sts" {
  #count = var.create_vpce_private_rosa_cluster ? 1 : 0

  service_name      = "com.amazonaws.${var.aws_region}.sts"
  #vpc_id            = data.aws_vpc.get_rosa_vpc.id
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  subnet_ids          = data.aws_subnets.private_subnets.ids
  security_group_ids = [
    aws_security_group.authorize_inbound_vpc_traffic.id
  ]

  tags = {
    Name    = "sts"
    service = "ROSA"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  count = var.create_vpce_private_rosa_cluster ? 1 : 0

  service_name      = "com.amazonaws.${var.aws_region}.ecr.api"
  #vpc_id            = data.aws_vpc.get_rosa_vpc.id
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  subnet_ids          = data.aws_subnets.private_subnets.ids
  security_group_ids = [
    aws_security_group.authorize_inbound_vpc_traffic.id
  ]

  tags = {
    Name    = "ecr_api"
    service = "ROSA"
  }
}

# https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html
resource "aws_vpc_endpoint" "ecr_dkr" {
  count = var.create_vpce_private_rosa_cluster ? 1 : 0

  service_name      = "com.amazonaws.${var.aws_region}.ecr.dkr"
  #vpc_id            = data.aws_vpc.get_rosa_vpc.id
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  subnet_ids          = data.aws_subnets.private_subnets.ids
  security_group_ids = [
    aws_security_group.authorize_inbound_vpc_traffic.id
  ]

  tags = {
    Name    = "ecr_dkr"
    service = "ROSA"
  }
}