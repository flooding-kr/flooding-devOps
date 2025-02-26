variable "vpc_cidr" {
  description = "10.0.0.0/20"
  type        = string
}

variable "environment" {
  description = "flooding"
  type        = string
}

variable "public_subnet_cidr" {
  description = "10.0.1.0/24"
  type        = string
} 

variable "azs" {
  description = "ap-northeast-2"
  type = list(string)
}
variable "private_subnet_cidr" {
    description = "10.0.2.0/24"
    type = string
}