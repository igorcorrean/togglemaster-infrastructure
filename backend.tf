# Backend remoto (Fase 3 - requisito de Estado)
#
# O bucket S3 usado abaixo precisa existir ANTES do `terraform init`.
# Use o projeto em ./bootstrap para criá-lo (veja bootstrap/README.md),
# ou crie manualmente um bucket com versionamento habilitado.
#
# use_lockfile = true habilita o lock nativo do S3 (Terraform >= 1.10),
# dispensando o uso de uma tabela DynamoDB para lock.

terraform {
  backend "s3" {
    bucket       = "togglemaster-terraform-state-271384503138" # ajuste para o nome real do seu bucket (globalmente único)
    key          = "phase3/toggle-master/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
