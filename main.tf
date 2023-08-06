resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public" {
  for_each = {
    for index, az_name in 
      slice(data.aws_availability_zones.available.names, 0, var.number_of_availability_zones)
      : az_name => cidrsubnet(aws_vpc.main.cidr_block, local.subnet_newbits, index)
      if var.enable_public_subnets
  }

  vpc_id = aws_vpc.main.id
  availability_zone = each.key
  cidr_block = each.value

  map_public_ip_on_launch = true
}

resource "aws_subnet" "nat" {
  for_each = {
    for index, az_name in 
      slice(data.aws_availability_zones.available.names, 0, var.number_of_availability_zones)
      : az_name => cidrsubnet(aws_vpc.main.cidr_block, local.subnet_newbits, index + var.number_of_availability_zones)
      if var.enable_nat_subnets
  }

  vpc_id = aws_vpc.main.id
  availability_zone = each.key
  cidr_block = each.value
}

resource "aws_subnet" "private" {
  for_each = {
    for index, az_name in 
      slice(data.aws_availability_zones.available.names, 0, var.number_of_availability_zones)
      : az_name => cidrsubnet(aws_vpc.main.cidr_block, local.subnet_newbits, index + (2 * var.number_of_availability_zones))
      if var.enable_private_subnets
  }

  vpc_id = aws_vpc.main.id
  availability_zone = each.key
  cidr_block = each.value
}
