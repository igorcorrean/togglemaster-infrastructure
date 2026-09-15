output "endpoints" {
  description = "Mapa <chave> => endpoint:porta de cada instância RDS"
  value       = { for k, v in aws_db_instance.this : k => v.endpoint }
}

output "addresses" {
  description = "Mapa <chave> => hostname (sem porta) de cada instância RDS"
  value       = { for k, v in aws_db_instance.this : k => v.address }
}

output "db_names" {
  value = { for k, v in aws_db_instance.this : k => v.db_name }
}

output "security_group_id" {
  value = aws_security_group.rds.id
}
