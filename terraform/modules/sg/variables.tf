variable "vpc_id" {
  description = "vpc_id"
  type        = string
} 

variable "vpc_cidr" {
  type = list(string)
}