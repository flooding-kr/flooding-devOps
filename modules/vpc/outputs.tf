output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "생성된 퍼블릭 서브넷의 ID"
  value       = module.vpc.public_subnets[0]
} 

output "private_subnet_id" {
  description = "private subnet id"
  value       = module.vpc.private_subnets[0]
}