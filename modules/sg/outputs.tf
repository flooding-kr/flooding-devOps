output "server_sg_id" {
  description = "server_sg_id"
  value       = aws_security_group.server.id
}

output "db_sg_id" {
  description = "db_sg_id"
  value       = aws_security_group.db.id
} 

output "alb_sg_id"{
  description = "alb_sg_id"
  value = aws_security_group.alb.id
}