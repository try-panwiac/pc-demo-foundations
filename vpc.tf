resource "aws_vpc" "demo-foundations-vpc" {
  cidr_block = var.vpc.demo_foundations_vpc.cidr_block
  tags = {
    Name = var.vpc.demo_foundations_vpc.name
  }
}

resource "aws_subnet" "public-subnet" {
  cidr_block = var.public_subnet.cidr_block
  vpc_id     = aws_vpc.demo-foundations-vpc.id
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  cidr_block = var.internal_subnet.cidr_block
  vpc_id     = aws_vpc.demo-foundations-vpc.id
  tags = {
    Name = "internal-subnet"
  }
}

resource "aws_internet_gateway" "demo-foundations-igw" {
  vpc_id = aws_vpc.demo-foundations-vpc.id
  tags = {
    Name = "demo-foundations-igw"
  }
}

resource "aws_nat_gateway" "demo-foundations-nat-gw" {
  allocation_id = aws_eip.demo-foundations-eip.id
  subnet_id     = aws_subnet.public-subnet.id
  tags = {
    Name = "demo-foundations-nat-gw"
  }
}

resource "aws_eip" "demo-foundations-eip" {
  vpc = true
}

resource "aws_route_table" "demo-private" {
  vpc_id = aws_vpc.demo-foundations-vpc.id
  tags = {
    Name = "demo-private"
  }
}

resource "aws_route" "private_default_route" {
  route_table_id = aws_route_table.demo-private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.demo-foundations-nat-gw.id
}

resource "aws_route_table" "demo-public" {
  vpc_id = aws_vpc.demo-foundations-vpc.id
  tags = {
    Name = "demo-public"
  }
}

resource "aws_route" "public_default_route" {
  route_table_id = aws_route_table.demo-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.demo-foundations-igw.id
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.demo-private.id
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.demo-public.id
}