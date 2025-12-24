locals {

  route_tables = concat(
    data.aws_route_tables.private.ids,
    data.aws_route_tables.public.ids
  )
}