# ToggleMaster — Infraestrutura Terraform (Fase 3)

Provisiona toda a infraestrutura AWS usada pelos 5 microsserviços do
ToggleMaster: VPC, EKS, 3x RDS PostgreSQL, ElastiCache Redis, DynamoDB, SQS e
5 repositórios ECR.

## Estrutura

```
toggle-master-infra/
├── bootstrap/          # cria o bucket S3 do backend remoto (rodar 1x, antes de tudo)
├── modules/
│   ├── networking/      # VPC, subnets públicas/privadas, IGW, NAT, route tables
│   ├── eks/              # cluster EKS + managed node group + IAM (ou reaproveita LabRole)
│   ├── rds/               # 3 instâncias RDS PostgreSQL
│   ├── elasticache/       # Redis
│   ├── dynamodb/          # tabela ToggleMasterAnalytics
│   ├── sqs/               # fila de eventos
│   └── ecr/               # 5 repositórios de imagem
├── providers.tf
├── backend.tf
├── variables.tf
├── main.tf
├── outputs.tf
└── terraform.tfvars.example
```

## Passo a passo

1. **Backend remoto (uma única vez):**
   ```powershell
   cd bootstrap
   terraform init
   terraform apply -var="bucket_name=SEU-BUCKET-UNICO"
   cd ..
   ```
   Ajuste o nome do bucket em `backend.tf`.

2. **Configurar variáveis:**
   ```powershell
   Copy-Item terraform.tfvars.example terraform.tfvars
   # edite terraform.tfvars (senha do RDS, região, etc.)
   ```

3. **AWS Academy (LabRole):** defina em `terraform.tfvars`:
   ```hcl
   existing_iam_role_arn = "arn:aws:iam::<conta>:role/LabRole"
   ```
   Nesse caso o módulo `eks` não cria nenhuma role/policy de IAM nem o
   OIDC provider (IRSA), reaproveitando a LabRole no cluster e no node group.

4. **Provisionar:**
   ```powershell
   terraform init
   terraform plan
   terraform apply
   ```

5. **Configurar kubectl:**
   ```powershell
   aws eks update-kubeconfig --region us-east-1 --name togglemaster-eks
   ```

## Observações de segurança

- A senha do RDS (`rds_password`) nunca deve ir para `terraform.tfvars`
  commitado — prefira `TF_VAR_rds_password` como variável de ambiente em
  CI/CD (GitHub Actions secret).
- Os security groups de RDS/Redis só liberam tráfego a partir do security
  group do cluster EKS (`module.eks.cluster_security_group_id`).
- `terraform.tfstate` fica no S3 (nunca local), com versionamento e
  criptografia habilitados, e lock nativo via `use_lockfile`.
