output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security Group principal do cluster EKS compartilhado com os worker nodes"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "control_plane_security_group_id" {
  description = "Security Group adicional da control plane"
  value       = aws_security_group.cluster.id
}

output "oidc_provider_arn" {
  value = var.existing_iam_role_arn == null ? aws_iam_openid_connect_provider.this[0].arn : null
}

output "oidc_provider_url" {
  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "node_role_arn" {
  value = local.node_role_arn
}
