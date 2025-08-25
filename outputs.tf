output "ab_rosa_public_subnet" {
  #value       = aws_subnet.rosa_public_subnets[*] # works
  value       = [for s in aws_subnet.rosa_public_subnets : s.id]
  description = "AB     ---- The ID of the subnet."
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

output "vpc_id" {
  value = data.aws_vpc.get_rosa_vpc
}

output "private_route_table" {
   value = data.aws_route_tables.private.ids
}