output "instance_id" {
  description = "생성된 EC2 인스턴스의 ID"
  value       = aws_instance.server.id
}

output "public_ip" {
  description = "EC2 인스턴스의 퍼블릭 IP"
  value       = aws_instance.server.public_ip
} 