resource "aws_instance" "db" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids

  tags = {
    Name        = "${var.environment}-db-instance"
    Environment = var.environment
  }
}
