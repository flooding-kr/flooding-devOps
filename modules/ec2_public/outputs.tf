output "instance_id" {
  description = "생성된 EC2 인스턴스의 ID"
  value       = module.ec2_public.id
}

output "public_ip" {
  description = "EC2 인스턴스의 퍼블릭 IP"
  value       = module.ec2_public.public_ip
} 