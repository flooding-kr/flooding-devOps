output "instance_public_ip" {
  description = "EC2 인스턴스의 퍼블릭 IP"
  value       = module.ec2.public_ip
}

output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = module.vpc.vpc_id
} 