variable "security_group_id" {
  type = list(string)
}

variable "alb_name" {
  type = string
  
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = list(string)
}

variable "instance_id" {
  type = string
}