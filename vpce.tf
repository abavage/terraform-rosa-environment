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

## new 
resource "aws_vpc_endpoint" "ec2" {
  count = var.create_vpce_private_rosa_cluster ? 1 : 0

  service_name      = "com.amazonaws.${var.aws_region}.ec2"
  #vpc_id            = data.aws_vpc.get_rosa_vpc.id
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  subnet_ids          = data.aws_subnets.private_subnets.ids
  security_group_ids = [
    aws_security_group.authorize_inbound_vpc_traffic.id
  ]

  tags = {
    Name    = "ec2"
    service = "ROSA"
  }
}

resource "aws_vpc_endpoint" "elasticloadbalancing" {
  count = var.create_vpce_private_rosa_cluster ? 1 : 0

  service_name      = "com.amazonaws.${var.aws_region}.elasticloadbalancing"
  #vpc_id            = data.aws_vpc.get_rosa_vpc.id
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  subnet_ids          = data.aws_subnets.private_subnets.ids
  security_group_ids = [
    aws_security_group.authorize_inbound_vpc_traffic.id
  ]

  tags = {
    Name    = "elasticloadbalancing"
    service = "ROSA"
  }
}

resource "aws_vpc_endpoint" "tagging" {
  count = var.create_vpce_private_rosa_cluster ? 1 : 0

  service_name      = "com.amazonaws.${var.aws_region}.tagging"
  #vpc_id            = data.aws_vpc.get_rosa_vpc.id
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  subnet_ids          = data.aws_subnets.private_subnets.ids
  security_group_ids = [
    aws_security_group.authorize_inbound_vpc_traffic.id
  ]

  tags = {
    Name    = "tagging"
    service = "ROSA"
  }
}

resource "aws_vpc_endpoint" "servicequotas" {
  count = var.create_vpce_private_rosa_cluster ? 1 : 0

  service_name      = "com.amazonaws.${var.aws_region}.servicequotas"
  #vpc_id            = data.aws_vpc.get_rosa_vpc.id
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  subnet_ids          = data.aws_subnets.private_subnets.ids
  security_group_ids = [
    aws_security_group.authorize_inbound_vpc_traffic.id
  ]

  tags = {
    Name    = "servicequotas"
    service = "ROSA"
  }
}

resource "aws_vpc_endpoint" "kms" {
  count = var.create_vpce_private_rosa_cluster ? 1 : 0

  service_name      = "com.amazonaws.${var.aws_region}.kms"
  #vpc_id            = data.aws_vpc.get_rosa_vpc.id
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  subnet_ids          = data.aws_subnets.private_subnets.ids
  security_group_ids = [
    aws_security_group.authorize_inbound_vpc_traffic.id
  ]

  tags = {
    Name    = "kms"
    service = "ROSA"
  }
}




# cross region
resource "aws_vpc_endpoint" "iam" {
  count = var.create_vpce_private_rosa_cluster ? 1 : 0

  service_name      = "com.amazonaws.iam"
  #vpc_id            = data.aws_vpc.get_rosa_vpc.id
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Interface"
  service_region = "us-east-1"

  #private_dns_enabled = true
  #subnet_ids          = data.aws_subnets.private_subnets.ids
  #security_group_ids = [
  #  aws_security_group.authorize_inbound_vpc_traffic.id
  #]

  tags = {
    Name    = "iam"
    service = "ROSA"
  }
}

resource "aws_vpc_endpoint" "route53" {
  count = var.create_vpce_private_rosa_cluster ? 1 : 0

  service_name      = "com.amazonaws.route53"
  #vpc_id            = data.aws_vpc.get_rosa_vpc.id
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Interface"
  service_region = "us-east-1"

  #private_dns_enabled = true
  #subnet_ids          = data.aws_subnets.private_subnets.ids
  #security_group_ids = [
  #  aws_security_group.authorize_inbound_vpc_traffic.id
  #]

  tags = {
    Name    = "route53"
    service = "ROSA"
  }
}
