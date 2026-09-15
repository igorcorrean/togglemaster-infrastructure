variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}
variable "private_subnet_ids" {
  type = list(string)
}

variable "source_security_group_id" {
  description = "Security group (ex: do cluster EKS) autorizado a acessar o RDS"
  type        = string
}

variable "databases" {
  type = map(object({
    db_name = string
  }))
}

variable "instance_class" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "allocated_storage" {
  type = number
}

variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}
