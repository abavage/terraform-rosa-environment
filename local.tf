locals {
  # for aws_vpc_endpoint.s3
  route_tables = concat(
    data.aws_route_tables.private.ids,
    data.aws_route_tables.public.ids
  )

}