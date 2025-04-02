variable "region" {
  default = "ap-northeast-2"
  type    = string
}

variable "environment" {
  default = "prod"
  type    = string
}

variable "key_name" {
  default = "flooding-key"
  type    = string
}

variable "image_tag" {
  default = "latest"
  type = string
}