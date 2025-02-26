resource "aws_instance" "server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnet_id

  tags = {
    Name        = "${var.environment}-instance"
    Environment = var.environment
  }
} 