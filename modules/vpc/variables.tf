variable "vpc_cidr" {
  default = "10.0.0.0/20"
  type        = string
}

variable "environment" {
  default = "flooding"
  type        = string
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
  type        = string
} 

variable "azs" {
  default = "ap-northeast-2"
  type = string
}
variable "private_subnet_cidr" {
    default = "10.0.2.0/24"
    type = string
}