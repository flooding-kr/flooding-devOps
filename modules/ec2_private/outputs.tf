output "instance_id" {
  description = "생성된 EC2 인스턴스의 ID"
  value       = aws_instance.db.id
}
