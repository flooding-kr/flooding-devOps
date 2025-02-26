output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "생성된 퍼블릭 서브넷의 ID"
  value       = aws_subnet.public.id
} 

output "private_subnet_id" {
  description = "private subnet id"
  value = aws_subnet.private.id
}