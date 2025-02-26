variable "ami_id" {
  description = "EC2 인스턴스의 AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "EC2 인스턴스가 생성될 서브넷 ID"
  type        = string
}

variable "environment" {
  description = "환경 이름 (예: dev, prod)"
  type        = string
} 