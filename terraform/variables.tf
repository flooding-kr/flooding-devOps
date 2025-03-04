variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "ami_id" {
  description = "Ubuntu 24.04 LTS (서울 리전)"
  type        = string
  default     = "ami-024ea438ab0376a47"
}

variable "vpc_cidr" {
  type    = list(string)
  default = ["10.0.0.0/20"]

}

