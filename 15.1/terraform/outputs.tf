output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "aws-id-private-subnet" {
  value = aws_subnet.private.id
}

output "aws-id-public-subnet" {
  value = aws_subnet.public.id
}

output "server1_public_ip" {
  description = "Server1 public ip for ssh access"
  value       = aws_instance.server1[0].public_ip
}
output "server2_public_ip" {
  description = "Server2 public ip for ssh access"
  value       = aws_instance.server2[0].public_ip
}
output "server1_public_dns" {
  description = "Server1 public DNS"
  value       = aws_instance.server1[0].public_dns
}
output "server2_public_dns" {
  description = "Server2 public DNS"
  value       = aws_instance.server2[0].public_dns
}
output "region" {
  value = "us-east-2"
}