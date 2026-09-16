variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  description = "Versão do Kubernetes para o cluster EKS"
  type = string
  default = "1.34"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "node_instance_types" {
  type = list(string)
}

variable "node_desired_size" {
  type = number
}

variable "node_min_size" {
  type = number
}

variable "node_max_size" {
  type = number
}

variable "existing_iam_role_arn" {
  description = "ARN de role existente (ex: LabRole) para reaproveitar no cluster e nós. null cria roles novas."
  type        = string
  default     = null
}
