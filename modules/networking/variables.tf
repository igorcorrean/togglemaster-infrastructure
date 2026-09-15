variable "project_name" {
  type = string
}

variable "cluster_name" {
  description = "Usado apenas para as tags kubernetes.io/cluster/<name> exigidas pelo EKS"
  type        = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}
