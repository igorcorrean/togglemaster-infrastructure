output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "eks_oidc_provider_url" {
  value = module.eks.oidc_provider_url
}

output "rds_endpoints" {
  description = "Endpoints (host:port) das instâncias RDS, por microsserviço"
  value       = module.rds.endpoints
  sensitive   = true
}

output "redis_primary_endpoint" {
  value = module.elasticache.primary_endpoint
}

output "dynamodb_table_name" {
  value = module.dynamodb.table_name
}

output "sqs_queue_url" {
  value = module.sqs.queue_url
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "kubeconfig_command" {
  description = "Comando para configurar o kubectl após o apply"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
