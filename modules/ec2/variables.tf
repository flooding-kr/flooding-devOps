variable "ami_id" {
  description = "EC2 인스턴스의 AMI ID"
  type        = string
  default = "ami-024ea438ab0376a47"
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.small"
}



variable "environment" {
  description = "환경 이름 (예: dev, prod)"
  type        = string
  default = "prod"
} 