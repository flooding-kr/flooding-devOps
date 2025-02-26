output "backend_sg_id" {
  description = "backend_sg_id"
  value       = module.backend-sg.security_group_id
}

output "db_sg_id" {
  description = "db_sg_id"
  value       = module.db-sg.security_group_id
} 

output "alb_sg_id"{
  description = "alb_sg_id"
  value = module.alb-sg.security_group_id
}