module "networking" {
  source = "./modules/networking"

  project_name         = var.project_name
  cluster_name         = var.cluster_name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
}

module "eks" {
  source = "./modules/eks"

  cluster_name           = var.cluster_name
  cluster_version        = var.cluster_version
  vpc_id                 = module.networking.vpc_id
  private_subnet_ids     = module.networking.private_subnet_ids
  public_subnet_ids      = module.networking.public_subnet_ids
  node_instance_types    = var.node_instance_types
  node_desired_size      = var.node_desired_size
  node_min_size          = var.node_min_size
  node_max_size          = var.node_max_size
  existing_iam_role_arn  = var.existing_iam_role_arn
}

module "rds" {
  source = "./modules/rds"

  project_name              = var.project_name
  vpc_id                    = module.networking.vpc_id
  private_subnet_ids        = module.networking.private_subnet_ids
  source_security_group_id  = module.eks.cluster_security_group_id
  databases                 = var.rds_databases
  instance_class             = var.rds_instance_class
  engine_version             = var.rds_engine_version
  allocated_storage          = var.rds_allocated_storage
  username                   = var.rds_username
  password                   = var.rds_password
}

module "elasticache" {
  source = "./modules/elasticache"

  project_name              = var.project_name
  vpc_id                    = module.networking.vpc_id
  private_subnet_ids        = module.networking.private_subnet_ids
  source_security_group_id  = module.eks.cluster_security_group_id
  node_type                 = var.redis_node_type
  engine_version             = var.redis_engine_version
}

module "dynamodb" {
  source = "./modules/dynamodb"

  table_name = var.dynamodb_table_name
  hash_key   = var.dynamodb_hash_key
}

module "sqs" {
  source = "./modules/sqs"

  queue_name = var.sqs_queue_name
}

module "ecr" {
  source = "./modules/ecr"

  repository_names = var.ecr_repositories
}
