#Creates the subnet group where the RDS is going to be anchored

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "pc-demo-foundations-db-subnet-group"
  subnet_ids = [aws_subnet.private-subnet.id, aws_subnet.private2-subnet.id]
  tags = {
    Name = "pc-demo-foundations-db-subnet-group"
  }
}

#Creates the RDS database in the private subnet with hardcoded settings
resource "aws_db_instance" "internal_db" {
  engine = "mysql"
  engine_version = "8.0.28"
  instance_class = "db.t2.micro"
  storage_type         = "gp2"
  allocated_storage = 20
  username             = "admin"
  password             = "my_password01"
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.db.id]

  tags = {
    Name = "demo_db"
  }
}

#Creates the SG for the RDS database
resource "aws_security_group" "db" {
  name = "demo_db_sg"
  vpc_id     = aws_vpc.demo-foundations-vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public-subnet.cidr_block, aws_subnet.private-subnet.cidr_block]
  }

  tags = {
    Name = "demo_db_sg"
  }
  depends_on = [aws_vpc.demo-foundations-vpc]
}