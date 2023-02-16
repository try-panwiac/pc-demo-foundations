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

resource "aws_cloudwatch_log_group" "demo_flow_log_group" {
  name = "demo_flow-log-group"
}

resource "aws_flow_log" "demo_flow_log" {
  iam_role_arn = aws_iam_role.demo_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.demo_flow_log_group.arn
  traffic_type = "ALL"
  vpc_id = aws_vpc.demo-foundations-vpc.id
}

resource "aws_iam_role" "demo_flow_log_role" {
  name = "demo_flow_log_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "demo_flow_log_policy" {
  name = "demo_flow_log_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = aws_cloudwatch_log_group.demo_flow_log_group.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "flow_log_role_policy" {
  policy_arn = aws_iam_policy.demo_flow_log_policy.arn
  role = aws_iam_role.demo_flow_log_role.name
}

resource "aws_iam_role" "demo-insecure-role" {
  name = "demo_insecure-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "demo-insecure-pa" {
  policy_arn = aws_iam_policy.demo-insecure-policy.arn
  role       = aws_iam_role.demo-insecure-role.name
}

resource "aws_iam_instance_profile" "demo-insecure-profile" {
  name = "demo-insecure-profile"
  role = aws_iam_role.demo-insecure-role.name
}

resource "aws_iam_policy" "demo-insecure-policy" {
  name        = "demo-insecure-policy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "iam:PassRole",
          "ec2:RunInstances",
          "lambda:InvokeFunction"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_instance" "bastion" {
  ami           = var.bastion_ami
  instance_type = var.bastion_instance_type
  subnet_id     = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name      = var.ssh_key_name
  tags = {
    Name = "demo-bastion"
  }
}

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  vpc      = true
}

resource "aws_instance" "vulnerable" {
  ami           = var.vulnerable_ami
  instance_type = var.vulnerable_instance_type
  subnet_id     = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.vulnerable_sg.id]
  iam_instance_profile = aws_iam_instance_profile.demo-insecure-profile.name
  key_name      = var.ssh_key_name
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y openjdk-11-jdk
    git clone https://github.com/alexandre-cezar/log4shell-vulnerable-app.git
    sudo apt-get install -y maven
    cd log4shell-vulnerable-app
    ./gradlew appRun &
  EOF
  tags = {
    Name = "demo-vulnerable"
  }
}

resource "aws_eip" "vulnerable" {
  instance = aws_instance.vulnerable.id
  vpc      = true
}

resource "aws_instance" "internal" {
  ami           = var.internal_ami
  instance_type = var.internal_instance_type
  subnet_id     = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.internal_sg.id]
  key_name      = var.ssh_key_name
  tags = {
    Name = "demo-internal"
  }
}

resource "aws_security_group" "bastion_sg" {
  name = "bastion_sg"
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
    cidr_blocks = [aws_subnet.public-subnet.cidr_block, aws_subnet.private-subnet.cidr_block]
  }

  egress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    cidr_blocks = [aws_subnet.public-subnet.cidr_block, aws_subnet.private-subnet.cidr_block]
  }
  tags = {
    Name = "demo-bastion-sg"
  }
}

resource "aws_security_group" "vulnerable_sg" {
  name = "vulnerable_sg"
  vpc_id     = aws_vpc.demo-foundations-vpc.id

  ingress {
    from_port = 80
    to_port   = 80
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
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    cidr_blocks = [aws_subnet.private-subnet.cidr_block]
  }
  tags = {
    Name = "demo-vulnerable-sg"
  }
}

resource "aws_security_group" "internal_sg" {
  name = "internal_sg"
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
    cidr_blocks = [aws_subnet.private-subnet.cidr_block]
  }

  egress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    cidr_blocks = [aws_subnet.private-subnet.cidr_block]
  }
  tags = {
    Name = "demo-internal-sg"
  }
}

resource "aws_db_instance" "internal_db" {
  engine = "mysql"
  engine_version = "8.0.28"
  instance_class = "db.t2.micro"
  storage_type         = "gp2"
  allocated_storage = 20
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.db.id]

  tags = {
    Name = "exampledb"
  }
}

resource "aws_security_group" "db" {
  name = "db_sg"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public-subnet.cidr_block, aws_subnet.private-subnet.cidr_block]
  }

  tags = {
    Name = "db-sg"
  }
}