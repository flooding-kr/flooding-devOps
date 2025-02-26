variable "vpc_cidr" {
  description = "VPC의 CIDR 블록"
  type        = string
}

variable "environment" {
  description = "환경 이름 (예: dev, prod)"
  type        = string
}

variable "public_subnet_cidr" {
  description = "퍼블릭 서브넷의 CIDR 블록"
  type        = string
} 