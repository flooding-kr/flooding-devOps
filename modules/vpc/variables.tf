variable "vpc_cidr" {
  default = "vpc_cidr"
  type        = string
}

variable "vpc_name" {
  description = "vpc_name"
  type = string
}

variable "public_subnet_cidr" {
  type = list(string)
  default = [ "10.0.1.0/24" ]
} 

variable "azs" {
  default = ["ap-northeast-2a"]
  type = list(string)
}
variable "private_subnet_cidr" {
    type = list(string)
    default = [ "10.0.2.0/24" ]
}