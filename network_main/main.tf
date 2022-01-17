data "aws_availability_zones" "available" {}

# VPC Setup-----------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  tags = {
    Name = "${var.env}-vpc"
  }
}

# Internet GW--------------------------
resource "aws_internet_gateway" "main-gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-igw"
  }
}

# Public Subnets------------------------
resource "aws_subnet" "main-public" {
  count                   = length(var.public_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidr_blocks, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.env}-public-${count.index + 1}"
  }
}

# Route Table for Public
resource "aws_route_table" "main-public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-gw.id
  }
  tags = {
    Name = "${var.env}-route-public-subnets"
  }
}

# Route Associations public
resource "aws_route_table_association" "main-public" {
  count          = length(aws_subnet.main-public[*].id)
  subnet_id      = element(aws_subnet.main-public[*].id, count.index)
  route_table_id = aws_route_table.main-public.id
}


# NAT GW--------------------------------------------
resource "aws_eip" "nat" {
  vpc = true
  tags = {
    "Name" = "${var.env}-nat-gw"
  }
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.main-public[1].id
  depends_on    = [aws_subnet.main-public]
  tags = {
    Name = "${var.env}-nat-gw"
  }
}

# Private Subnets--------------------------
resource "aws_subnet" "main-private" {
  count                   = length(var.private_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.private_subnet_cidr_blocks, count.index)
  map_public_ip_on_launch = "false"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.env}-private-${count.index + 1}"
  }
}

# Route Table setup for Private through NAT
resource "aws_route_table" "main-private" {
  count                   = length(var.private_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "${var.env}route-private-subnet"
  }
}

# Route Associations private
resource "aws_route_table_association" "main-private" {
  count     = length(aws_subnet.main-private[*].id)
  subnet_id = element(aws_subnet.main-private[*].id, count.index)
  route_table_id = aws_route_table.main-private[count.index].id
}