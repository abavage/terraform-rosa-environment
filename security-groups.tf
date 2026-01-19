resource "aws_security_group" "rds" {
  name        = "rds-security-group"
  description = "rds-security-group"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "rds-security-group"
  }
  depends_on = [
    aws_vpc.main
  ]
}

resource "aws_vpc_security_group_ingress_rule" "rds_ingress_rules" {
  for_each = var.common_ec2_sg_rules

  security_group_id = aws_security_group.rds.id
  from_port         = 5432
  to_port           = 5432
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"

  depends_on = [
    aws_security_group.rds
  ]
}

resource "aws_vpc_security_group_egress_rule" "rds_allow_all" {
  security_group_id = aws_security_group.rds.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  depends_on = [
    aws_security_group.rds
  ]
}
