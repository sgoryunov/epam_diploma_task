resource "aws_security_group" "rds_security_group" {
  name_prefix = "rds_security_group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}
resource "aws_db_subnet_group" "education-vpc" {
  name       = "education-vpc"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "education-vpc"
  }
}
resource "aws_db_instance" "itunes-gr_db" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.db_user
  password             = var.db_user_pass
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  identifier = "sgoryunov-db"
  db_subnet_group_name = resource.aws_db_subnet_group.education-vpc.name
  vpc_security_group_ids = [resource.aws_security_group.rds_security_group.id]
}