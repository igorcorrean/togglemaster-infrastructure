# ---------- IAM: Cluster role ----------
# Se existing_iam_role_arn for informado (cenário AWS Academy/LabRole), reaproveita essa role
# e não cria nenhuma role/policy nova. Em conta pessoal, cria roles dedicadas.

data "aws_iam_role" "existing" {
  count = var.existing_iam_role_arn != null ? 1 : 0
  name  = element(split("/", var.existing_iam_role_arn), length(split("/", var.existing_iam_role_arn)) - 1)
}

resource "aws_iam_role" "cluster" {
  count = var.existing_iam_role_arn == null ? 1 : 0
  name  = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  count      = var.existing_iam_role_arn == null ? 1 : 0
  role       = aws_iam_role.cluster[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ---------- IAM: Node role ----------

resource "aws_iam_role" "node" {
  count = var.existing_iam_role_arn == null ? 1 : 0
  name  = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  count      = var.existing_iam_role_arn == null ? 1 : 0
  role       = aws_iam_role.node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  count      = var.existing_iam_role_arn == null ? 1 : 0
  role       = aws_iam_role.node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_readonly" {
  count      = var.existing_iam_role_arn == null ? 1 : 0
  role       = aws_iam_role.node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

locals {
  cluster_role_arn = var.existing_iam_role_arn != null ? var.existing_iam_role_arn : aws_iam_role.cluster[0].arn
  node_role_arn    = var.existing_iam_role_arn != null ? var.existing_iam_role_arn : aws_iam_role.node[0].arn
}

# ---------- EKS Cluster ----------

resource "aws_security_group" "cluster" {
  name_prefix = "${var.cluster_name}-cluster-sg-"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-cluster-sg"
  }
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = local.cluster_role_arn
  version  = "1.31" #teste

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    security_group_ids      = [aws_security_group.cluster.id]
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
  ]
}

# ---------- Managed Node Group ----------

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = local.node_role_arn
  subnet_ids      = var.private_subnet_ids
  ami_type        = "AL2023_x86_64_STANDARD"
  instance_types  = var.node_instance_types
  capacity_type   = "ON_DEMAND"

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_readonly,
  ]
}

# ---------- OIDC Provider (IRSA) ----------
# Só faz sentido em conta pessoal (Opção B), pois requer criar um recurso de IAM.
# Usado por controllers como o Nginx Ingress Controller e o KEDA para obter
# permissões via Service Account sem herdar a role inteira do nó.

resource "aws_iam_openid_connect_provider" "this" {
  count           = var.existing_iam_role_arn == null ? 1 : 0
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks[0].certificates[0].sha1_fingerprint]
}

data "tls_certificate" "eks" {
  count = var.existing_iam_role_arn == null ? 1 : 0
  url   = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
