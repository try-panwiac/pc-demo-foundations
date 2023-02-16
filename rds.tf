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
    Name = "demo_db"
  }
}

resource "aws_security_group" "db" {
  name = "demo_db_sg"

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