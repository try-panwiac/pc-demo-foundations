terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.67.0"
    }
  }
}

provider "aws" {
  region = var.region
}

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

resource "aws_subnet" "internal-subnet" {
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

resource "aws_instance" "vulnerable" {
  ami           = var.vulnerable_ami
  instance_type = var.vulnerable_instance_type
  subnet_id     = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.vulnerable_sg.id]
  key_name      = var.ssh_key
  tags = {
    Name = "vulnerable"
  }
}

resource "aws_eip" "vulnerable" {
  instance = aws_instance.vulnerable.id
  vpc      = true
}

resource "aws_instance" "bastion" {
  ami           = var.bastion_ami
  instance_type = var.bastion_instance_type
  subnet_id     = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name      = var.ssh_key
  tags = {
    Name = "bastion"
  }
}

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  vpc      = true
}

resource "aws_instance" "internal" {
  ami           = var.internal_ami
  instance_type = var.internal_instance_type
  subnet_id     = aws_subnet.internal-subnet.id
  vpc_security_group_ids = [aws_security_group.internal_sg.id]
  key_name      = var.ssh_key
  tags = {
    Name = "internal"
  }
}

resource "aws_security_group" "bastion_sg" {
  name_prefix = "bastion_sg-"
  vpc_id     = aws_vpc.demo-foundations-vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [aws_subnet.public-subnet.cidr_block, aws_subnet.internal-subnet.cidr_block]
  }

  egress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    cidr_blocks = [aws_subnet.public-subnet.cidr_block, aws_subnet.internal-subnet.cidr_block]
  }

  egress {
    from_port = 0
    to_port   = 65535
    protocol  = "icmp"
    cidr_blocks = [aws_subnet.public-subnet.cidr_block, aws_subnet.internal-subnet.cidr_block]
  }
}

resource "aws_security_group" "vulnerable_sg" {
  name_prefix = "vulnerable_sg-"
  vpc_id     = aws_vpc.demo-foundations-vpc.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    cidr_blocks = [aws_subnet.internal-subnet.cidr_block]
  }
}

resource "aws_security_group" "internal_sg" {
  name_prefix = "internal_sg-"
  vpc_id     = aws_vpc.demo-foundations-vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [aws_subnet.public-subnet.cidr_block]
  }

  egress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [aws_subnet.internal-subnet.cidr_block]
  }

  egress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    cidr_blocks = [aws_subnet.internal-subnet.cidr_block]
  }
}

resource "aws_db_instance" "internal_db" {
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  allocated_storage    = 20
  storage_type         = "gp2"
  identifier           = "demodb"
  name                 = "internaldb"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.db.id]

  tags = {
    Name = "exampledb"
  }
}

resource "aws_security_group" "db" {
  name_prefix = "db_sg-"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public-subnet.cidr_block, aws_subnet.internal-subnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_subnet.public-subnet.cidr_block, aws_subnet.internal-subnet.cidr_block]
  }

  tags = {
    Name = "db-sg"
  }
}