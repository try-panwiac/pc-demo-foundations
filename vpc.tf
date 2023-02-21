#Creates the VPC using the variable VPC object definitions
resource "aws_vpc" "demo-foundations-vpc" {
  cidr_block = var.vpc.demo_foundations_vpc.cidr_block
  tags = {
    Name = var.vpc.demo_foundations_vpc.name
  }
}

#Creates the public subnet using the variable public subnet object definitions
resource "aws_subnet" "public-subnet" {
  cidr_block = var.public_subnet.cidr_block
  vpc_id     = aws_vpc.demo-foundations-vpc.id
  tags = {
    Name = "public-subnet"
  }
}

#Creates the private subnet using the variable internal subnet object definitions
resource "aws_subnet" "private-subnet" {
  cidr_block = var.internal_subnet.cidr_block
  vpc_id     = aws_vpc.demo-foundations-vpc.id
  tags = {
    Name = "private-subnet"
  }
}

#Creates the Internet Gateway
resource "aws_internet_gateway" "demo-foundations-igw" {
  vpc_id = aws_vpc.demo-foundations-vpc.id
  tags = {
    Name = "demo-foundations-igw"
  }
}

#Creates the NAT Gateway
resource "aws_nat_gateway" "demo-foundations-nat-gw" {
  allocation_id = aws_eip.demo-foundations-eip.id
  subnet_id     = aws_subnet.public-subnet.id
  tags = {
    Name = "demo-foundations-nat-gw"
  }
}

#Creates an Elastic IP and attaches it with the NAT Gateway
resource "aws_eip" "demo-foundations-eip" {
  vpc = true
}

#Creates the private subnet routing table
resource "aws_route_table" "demo-private" {
  vpc_id = aws_vpc.demo-foundations-vpc.id
  tags = {
    Name = "demo-private"
  }
}

#Configures the default route of private subnet pointing to the NAT Gateway
resource "aws_route" "private_default_route" {
  route_table_id = aws_route_table.demo-private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.demo-foundations-nat-gw.id
}

#Creates the public subnet routing table
resource "aws_route_table" "demo-public" {
  vpc_id = aws_vpc.demo-foundations-vpc.id
  tags = {
    Name = "demo-public"
  }
}

#Configures the default route of public subnet pointing to the Internet Gateway
resource "aws_route" "public_default_route" {
  route_table_id = aws_route_table.demo-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.demo-foundations-igw.id
}

#Associates the private route table with the private subnet
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.demo-private.id
}

#Associates the public route table with the public subnet
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.demo-public.id
}