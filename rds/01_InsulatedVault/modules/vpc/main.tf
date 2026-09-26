resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = var.vpc_tags
  
}

# Subred Pública
resource "aws_subnet" "public_subnets" {
  for_each = { for subnet in var.public_subnet_cidr_objects : subnet.id => subnet }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch
  tags = { 
    Name = "public-subnet-${each.value.id}" 
    Purpose = each.value.purpose
  }
}

# Subred Privada
resource "aws_subnet" "private_subnets" {
  for_each = { for subnet in var.private_subnet_cidr_objects : subnet.id => subnet }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false
  tags = { 
    Name = "public-subnet-${each.value.id}" 
    Purpose = each.value.purpose
  }
}

# --- Componentes de Red ---

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main-igw" }
}

resource "aws_eip" "eip_nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

# The NAT gateway address is in the first public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id     = aws_subnet.public_subnets[keys(aws_subnet.public_subnets)[0]].id
  tags          = { Name = "main-nat-gateway" }
}

# --- Tablas de Enrutamiento ---

# Pública -> Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public_rt_association" {
  for_each = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

# Privada -> NAT Gateway
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "private-rt" }
}

resource "aws_route_table_association" "private_rt_association" {
  for_each = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}