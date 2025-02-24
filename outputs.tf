#data "aws_vpc" "get-rosa-vpc" {
#  filter {
#    name = "tag:Name"
#    values = ["rosa-private-three"]
#  }
#}
#
#output "got-the-rosa-vpc" {
#  value = data.aws_vpc.get-rosa-vpc.id
#}



output "ab_rosa_public_subnet" {
  #value       = aws_subnet.rosa_public_subnets[*] # works
  value       = [for s in aws_subnet.rosa_public_subnets : s.id]
  description = "AB     ---- The ID of the subnet."
}


#output "rosa_public_subnet_subnet_ids" {
#  value = [for s in data.ab_rosa_public_subnet : s.id]
#  description  = "THE ID MAYBE"
#}

output "ab_rosa_private_subnet" {
  #value       =     aws_subnet.rosa_private_subnet[*].id
  value       = aws_subnet.rosa_private_subnets[*]
  description = "AB     ---- The ID of the private subnet."
}


output "rosa_public_subnets" {
  value = data.aws_subnets.rosa_public_subnets
}

output "rosa_private_subnets" {
  value = data.aws_subnets.rosa_private_subnets
}

output "eips" {
  value = data.aws_eips.eips
}

output "availability_zones" {
  value = data.aws_availability_zones.availability_zones
}

output "aws_nat_gateways" {
  value = data.aws_nat_gateways.ngws
}

output "subnet_length" {
  value = length(var.rosa_public_subnet)
}




# get the subnets
#data "aws_subnets" "rosa_public_subnet" {
#  filter {
#    #name   = "vpc-id"
#    #values = [aws_vpc.vpc.id]
#    name   = "tag:Name"
#    values = ["rosa-public-subnet-*"]
#  }
#depends_on = [aws_subnet.rosa_public_subnets]
#}

#data "aws_subnet" "rosa_public_subnet" {
#  for_each = toset(data.aws_subnets.rosa_public_subnet.ids)
#  id       = each.value
#}

#output "rosa_public_subnet_subnet_ids" {
#  value = [for s in data.aws_subnet.rosa_public_subnet : s.id]
#}

#data "aws_subnets" "rosa_private_subnet" {
#  filter {
#    #name   = "vpc-id"
#    #values = [aws_vpc.vpc.id]
#    name   = "tag:Name"
#    values = ["rosa-private-subnet-*"]
#  }
#depends_on = [aws_subnet.rosa_private_subnets]
#}

#data "aws_subnet" "rosa_private_subnet" {
#  for_each = toset(data.aws_subnets.rosa_private_subnet.ids)
#  id       = each.value
#}

#output "rosa_private_subnet_subnet_ids" {
#  value = [for s in data.aws_subnet.rosa_private_subnet : s.id]
#}


#########################

#output "ids" {
#  value = [aws_nat_gateway.nat.*.id]
#}


#data "aws_eip" "nat_eips" {
#  filter {
#    name   = "tag:Name"
#    values = ["nat-*"]
#  }
#}

#output "aws_eip_nat_ips" {
#  value = [for i in data.aws_eip.nat_eips : i.id]
#}
