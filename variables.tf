variable "aws_region" {
  description = "Região AWS onde os recursos serão provisionados"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto, usado como prefixo/tag em todos os recursos"
  type        = string
  default     = "togglemaster"
}

variable "environment" {
  description = "Nome do ambiente (dev, hml, prod)"
  type        = string
  default     = "dev"
}

# ---------- Networking ----------

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability Zones utilizadas"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs das sub-redes públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs das sub-redes privadas"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "single_nat_gateway" {
  description = "Se true, cria apenas 1 NAT Gateway (economia) em vez de 1 por AZ"
  type        = bool
  default     = true
}

# ---------- EKS ----------

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
  default     = "togglemaster-eks"
}

variable "cluster_version" {
  description = "Versão do Kubernetes do cluster EKS"
  type        = string
  default     = "1.30"
}

variable "node_instance_types" {
  description = "Tipos de instância EC2 para o Managed Node Group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 4
}

# Uso opcional de uma role pré-existente (cenário AWS Academy / LabRole).
# Em conta pessoal, deixe null para que o módulo EKS crie suas próprias roles de IAM.
variable "existing_iam_role_arn" {
  description = "ARN de uma role de IAM existente (ex: LabRole) para reaproveitar no cluster/nós. Deixe null para criar roles novas."
  type        = string
  default     = null
}

# ---------- RDS (PostgreSQL) ----------

variable "rds_databases" {
  description = "Mapa de bancos de dados RDS PostgreSQL a serem criados (um por microsserviço)"
  type = map(object({
    db_name = string
  }))
  default = {
    auth      = { db_name = "auth_service" }
    flag      = { db_name = "flag_service" }
    targeting = { db_name = "targeting_service" }
  }
}

variable "rds_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "rds_engine_version" {
  type    = string
  default = "15.7"
}

variable "rds_allocated_storage" {
  type    = number
  default = 20
}

variable "rds_username" {
  description = "Usuário master das instâncias RDS"
  type        = string
  default     = "toggleadmin"
}

variable "rds_password" {
  description = "Senha master das instâncias RDS (defina via TF_VAR_rds_password ou terraform.tfvars, nunca commitado)"
  type        = string
  sensitive   = true
}

# ---------- ElastiCache (Redis) ----------

variable "redis_node_type" {
  type    = string
  default = "cache.t3.micro"
}

variable "redis_engine_version" {
  type    = string
  default = "7.1"
}

# ---------- DynamoDB ----------

variable "dynamodb_table_name" {
  type    = string
  default = "ToggleMasterAnalytics"
}

variable "dynamodb_hash_key" {
  type    = string
  default = "id"
}

# ---------- SQS ----------

variable "sqs_queue_name" {
  type    = string
  default = "togglemaster-events"
}

# ---------- ECR ----------

variable "ecr_repositories" {
  description = "Lista dos microsserviços que terão repositório no ECR"
  type        = list(string)
  default = [
    "auth-service",
    "flag-service",
    "targeting-service",
    "evaluation-service",
    "analytics-service",
  ]
}
