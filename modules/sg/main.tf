# 웹 서버용 보안 그룹
resource "aws_security_group" "alb" {
  name = "${var.environment}-alb-sg"
  description = "Security group for alb"
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

}


resource "aws_security_group" "server" {
  name        = "${var.environment}-server-sg"
  description = "Security group for server servers"
  vpc_id      = var.vpc_id

  # HTTP 접근 허용
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [ aws_security_group.alb.id ]
  }

  # HTTPS 접근 허용
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # SSH 접근 허용
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-server-sg"
    Environment = var.environment
  }
}

# 데이터베이스용 보안 그룹
resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Security group for database servers"
  vpc_id      = var.vpc_id

  # 웹 서버로부터의 MySQL/Aurora 접근 허용
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.server.id]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "ssh"
    security_groups = [ aws_security_group.server.id ]
  }
  ingress {
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    security_groups = [aws_security_group.server.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-db-sg"
    Environment = var.environment
  }
} 