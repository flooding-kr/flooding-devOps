output "instance_id" {
  description = "생성된 EC2 인스턴스의 ID"
  value       = module.ec2_private.id
}
