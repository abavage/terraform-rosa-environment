output "private_subnets" {
  value = data.aws_subnets.private_subnets.ids
}

output "public_subnets" {
  #value = data.aws_subnets.public_subnets.ids[0]
  value = try(data.aws_subnets.public_subnets.ids[0], null)

}




