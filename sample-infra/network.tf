# ===========
# VPC
# ===========
resource "aws_vpc" "sample_vpc" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.r_prefix}-vpc"
  }
}

# ===========
# Subnet
# ===========
###### public ######
resource "aws_subnet" "sample_public_subnet" {
  for_each                = var.subnets.public_subnets
  vpc_id                  = aws_vpc.sample_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.r_prefix}-${each.value.name}"
  }
}

###### private ######
resource "aws_subnet" "sample_private_subnet" {
  for_each                = var.subnets.private_subnets
  vpc_id                  = aws_vpc.sample_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.r_prefix}-${each.value.name}"
  }
}

# =================
# Internet GateWay
# =================
resource "aws_internet_gateway" "sample_igw" {
  vpc_id = aws_vpc.sample_vpc.id

  tags = {
    Name = "${var.r_prefix}-igw"
  }
}

# =================
# Rounte Table
# =================
###### public ######
# Route Table
resource "aws_route_table" "public" {
  for_each = var.subnets.public_subnets
  vpc_id   = aws_vpc.sample_vpc.id
  tags = {
    Name = "${var.r_prefix}-${each.value.name}-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  for_each       = var.subnets.public_subnets
  subnet_id      = aws_subnet.sample_public_subnet[each.key].id
  route_table_id = aws_route_table.public[each.key].id
}


# Route
resource "aws_route" "public" {
  for_each               = var.subnets.public_subnets
  route_table_id         = aws_route_table.public[each.key].id
  gateway_id             = aws_internet_gateway.sample_igw.id
  destination_cidr_block = "0.0.0.0/0"
}

###### private ######
# Route Table
resource "aws_route_table" "private" {
  for_each = var.subnets.private_subnets
  vpc_id   = aws_vpc.sample_vpc.id
  tags = {
    Name = "${var.r_prefix}-${each.value.name}-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "private" {
  for_each       = var.subnets.public_subnets
  subnet_id      = aws_subnet.sample_public_subnet[each.key].id
  route_table_id = aws_route_table.public[each.key].id
}

# Route
resource "aws_route" "ngw" {
  for_each               = zipmap(keys(var.subnets.public_subnets), keys(var.subnets.private_subnets))
  route_table_id         = aws_route_table.private[each.value].id
  nat_gateway_id         = aws_nat_gateway.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
}

# =============
# Elastic IP
# =============
resource "aws_eip" "nat_gateway" {
  for_each = var.subnets.public_subnets
  vpc      = true
  tags = {
    Name = "${var.r_prefix}-${each.value.name}-ngw-eip"
  }
}

# ==============
# Nat Gateway
# ==============
resource "aws_nat_gateway" "private" {
  for_each      = var.subnets.public_subnets
  allocation_id = aws_eip.nat_gateway[each.key].id
  subnet_id     = aws_subnet.sample_public_subnet[each.key].id
  tags = {
    Name = "${var.r_prefix}-${each.value.name}-ngw"
  }
  depends_on = [
    aws_internet_gateway.sample_igw
  ]
}