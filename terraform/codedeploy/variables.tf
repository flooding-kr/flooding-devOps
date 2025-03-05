
variable "deployment_group_name" {
  description = "codeDeploy DG name"
  type = string
}

variable "alb_name" {
  description = "flooding alb name"
  type = string
}
variable "asg_name" {
  default = "and"
  type = string
}