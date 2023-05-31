#Creates the EC2 instances, attach roles and run the scripts that will force trigger Attack Path policies and generates traffic for VPC flow logs
#owner: Alexandre Cezar

# Creates the role that will be attached to the insecure instance
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

# Creates the role that will be attached to the overpermissive instance
resource "aws_iam_role" "demo-overpermissive-role" {
  name = "demo_overpermissive-role"
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

# Attaches the insecure policy to the insecure role
resource "aws_iam_role_policy_attachment" "demo-insecure-pa" {
  policy_arn = aws_iam_policy.demo-insecure-policy.arn
  role       = aws_iam_role.demo-insecure-role.name
}

# Attaches the overpermissive policy to the overpermissive role
resource "aws_iam_role_policy_attachment" "demo-overpermissive-pa" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.demo-overpermissive-role.name
}

# Creates the instance profile
resource "aws_iam_instance_profile" "demo-insecure-profile" {
  name = "demo-insecure-profile"
  role = aws_iam_role.demo-insecure-role.name
}

# Creates the overpermissive instance profile
resource "aws_iam_instance_profile" "demo-overpermissive-profile" {
  name = "demo-overpermissive-profile"
  role = aws_iam_role.demo-overpermissive-role.name
}

# Creates the insecure IAM policy
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

# Creates the Bastion Host for access to the environment
resource "aws_instance" "bastion" {
  ami           = var.bastion_ami
  instance_type = var.bastion_instance_type
  subnet_id     = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name      = var.ssh_key_name
  tags = {
    Name = "demo-bastion"
  }
  depends_on = [aws_vpc.demo-foundations-vpc]
}

# Creates the vulnerable instance that will trigger the Hyperion policies
resource "aws_instance" "vulnerable" {
  ami           = var.vulnerable_ami
  instance_type = var.vulnerable_instance_type
  subnet_id     = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.vulnerable_sg.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.demo-insecure-profile.name
  key_name      = var.ssh_key_name
  tags = {
    Name = "demo-vulnerable"
  }

  depends_on = [aws_vpc.demo-foundations-vpc]

  # Connect to the Vulnerable instance via Terraform and remotely sets up the scripts using SSH
  provisioner "file" {
    source      = "${var.folder_scripts}/setup.sh"
    destination = "/home/ubuntu/setup.sh"
    connection {
      type = "ssh"
      host = aws_instance.vulnerable.public_ip
      user = "ubuntu"
      private_key = file(var.ssh_key_path)
    }
  }

  provisioner "file" {
    source      = "${var.folder_scripts}/prepare.sh"
    destination = "/home/ubuntu/prepare.sh"
    connection {
      type        = "ssh"
      host        = aws_instance.vulnerable.public_ip
      user        = "ubuntu"
      private_key = file(var.ssh_key_path)
    }
  }

  provisioner "file" {
    source      = "${var.folder_scripts}/port_scan.sh"
    destination = "/home/ubuntu/port_scan.sh"
  connection {
    type        = "ssh"
    host        = aws_instance.vulnerable.public_ip
    user        = "ubuntu"
    private_key = file(var.ssh_key_path)
    }
  }

  provisioner "file" {
    source      = "${var.folder_scripts}/suspicious_ip.sh"
    destination = "/home/ubuntu/suspicious_ip.sh"
  connection {
    type        = "ssh"
    host        = aws_instance.vulnerable.public_ip
    user        = "ubuntu"
    private_key = file(var.ssh_key_path)
    }
  }

  provisioner "file" {
    source      = "${var.folder_scripts}/log4j.sh"
    destination = "/home/ubuntu/log4j.sh"
    connection {
      type        = "ssh"
      host        = aws_instance.vulnerable.public_ip
      user        = "ubuntu"
      private_key = file(var.ssh_key_path)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ubuntu/setup.sh",
      "sudo /home/ubuntu/setup.sh"
    ]
    connection {
      type = "ssh"
      host = aws_instance.vulnerable.public_ip
      user = "ubuntu"
      private_key = file(var.ssh_key_path)
    }
  }
}

# Creates the internal instance that will be target of the port scans
resource "aws_instance" "internal" {
  ami           = var.internal_ami
  instance_type = var.internal_instance_type
  subnet_id     = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.internal_sg.id]
  key_name      = var.ssh_key_name
  user_data = <<EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    echo "Hello World" > /var/www/html/index.html
    systemctl start httpd
    systemctl enable httpd
  EOF
  tags = {
    Name = "demo-internal"
  }
  depends_on = [aws_vpc.demo-foundations-vpc]
}

# Creates the overpermissive instance that will trigger the IAM overpermissive roles
resource "aws_instance" "overpermissive" {
  ami           = var.overpermissive_ami
  instance_type = var.overpermissive_instance_type
  subnet_id     = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.internal_sg.id]
  iam_instance_profile = aws_iam_instance_profile.demo-overpermissive-profile.name
  key_name      = var.ssh_key_name
  tags = {
    Name = "demo-overpermissive"
  }
  depends_on = [aws_vpc.demo-foundations-vpc]
}

# Creates the Bastion SG
resource "aws_security_group" "bastion_sg" {
  name = "bastion_sg"
  vpc_id     = aws_vpc.demo-foundations-vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Update this value before applying to match your own IP
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

# Creates the Vulnerable SG
resource "aws_security_group" "vulnerable_sg" {
  name = "vulnerable_sg"
  vpc_id     = aws_vpc.demo-foundations-vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Update this value before applying to match your own IP
  }

  ingress {
    from_port = 8080
    to_port   = 8080
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
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [aws_subnet.private-subnet.cidr_block]
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

# Creates the Internal SG
resource "aws_security_group" "internal_sg" {
  name = "internal_sg"
  vpc_id     = aws_vpc.demo-foundations-vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [aws_subnet.public-subnet.cidr_block]
  }

  ingress {
    from_port = 80
    to_port   = 80
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
