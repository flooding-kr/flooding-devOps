variable "ami_id" {
  description = "EC2 AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 type"
  type        = string
}

variable "subnet_id" {
  type = string
}


variable "vpc_security_group_ids" {
  description = "Security group IDs for the instance"
  type        = list(string)
} 

variable "key_name" {
  type = string
  default = "flooding-key"
}