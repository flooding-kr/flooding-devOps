variable "vpc_cidr" {
  default = "vpc_cidr"
  type        = string
}

variable "environment" {
  default = "flooding"
  type        = string
}

variable "public_subnet_cidr" {
  default = "public_cidr"
  type        = string
} 

variable "azs" {
  default = "ap-northeast-2"
  type = string
}
variable "private_subnet_cidr" {
    default = "private_cidr"
    type = string
}