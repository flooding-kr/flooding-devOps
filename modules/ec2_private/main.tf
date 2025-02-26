resource "aws_instance" "db" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  tags = {
    Name        = "${var.environment}-db-instance"
    Environment = var.environment
  }
}
