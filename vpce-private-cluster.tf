resource "aws_security_group" "authorize_inbound_vpc_traffic" {
  vpc_id = data.aws_vpc.get_rosa_vpc.id
  name   = "private-cluster-vpce"
  description = "security grroup for private cluster vpce"

  tags = {
    service      = "ROSA"
    Name         = "private-cluster-vpce"
  }
    depends_on = [
    aws_vpc.vpc
  ]
}

# Ingress rules (one per subnet CIDR from the map)
resource "aws_vpc_security_group_ingress_rule" "allow_inbound_from_private_subnets" {
  for_each          = var.rosa_private_subnet
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
    depends_on = [
    aws_vpc.vpc
  ]
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
    depends_on = [
    aws_vpc.vpc
  ]
}



#resource "aws_vpc_endpoint" "sts" {
#  service_name      = "com.amazonaws.${var.aws_region}.sts"
#  vpc_id            = data.aws_vpc.get_rosa_vpc.id
#  vpc_endpoint_type = "Interface"

#  private_dns_enabled = true
#  subnet_ids          = data.aws_subnets.private_subnets.ids
#  security_group_ids  = [aws_security_group.authorize_inbound_vpc_traffic.id]

#  tags = {
#    Name         = "sts"
#    service      = "ROSA"
#  }
#    depends_on = [
#    aws_vpc.vpc
#  ]
#}


#resource "aws_vpc_endpoint" "ecr_api" {
# service_name      = "com.amazonaws.${var.aws_region}.ecr.api"
# vpc_id            = data.aws_vpc.get_rosa_vpc.id
# vpc_endpoint_type = "Interface"
#
# private_dns_enabled = true
# subnet_ids          = data.aws_subnets.private_subnets.ids
# security_group_ids  = [aws_security_group.authorize_inbound_vpc_traffic.id]
#
# tags = {
#   Name         = "ecr_api"
#   service      = "ROSA"
# }
#   depends_on = [
#   aws_vpc.vpc
# ]


# https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html
#esource "aws_vpc_endpoint" "ecr_dkr" {
# service_name      = "com.amazonaws.${var.aws_region}.ecr.dkr"
# vpc_id            = data.aws_vpc.get_rosa_vpc.id
# vpc_endpoint_type = "Interface"
#
# private_dns_enabled = true
# subnet_ids          = data.aws_subnets.private_subnets.ids
# security_group_ids  = [aws_security_group.authorize_inbound_vpc_traffic.id]
#
# tags = {
#   Name         = "ecr_dkr"
#   service      = "ROSA"
# }
#   depends_on = [
#   aws_vpc.vpc
# ]
#

# https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints-s3.html
resource "aws_vpc_endpoint" "s3" {
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = "Gateway"

  # Associate with route tables instead of subnets
  route_table_ids = local.route_tables
  

  tags = {
    Name         = "s3"
    service      = "ROSA"
  }
    depends_on = [
    aws_vpc.vpc
  ]
}







#resource "aws_vpc_endpoint" "secrets_manager" {
#  service_name      = "com.amazonaws.${var.aws_region}.secretsmanager" 
#  vpc_id            = data.aws_vpc.get_rosa_vpc.id
#  vpc_endpoint_type = "Interface"

#  private_dns_enabled = true
#  subnet_ids          = data.aws_subnets.private_subnets.ids
#  security_group_ids  = [aws_security_group.authorize_inbound_vpc_traffic.id]

#  tags = {
#    Name         = "secrets_manager"
#    service      = "ROSA"
#  }
#}
