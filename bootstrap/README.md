# Bootstrap do backend remoto

Este projeto Terraform separado cria **apenas** o bucket S3 usado como backend
remoto do state do projeto principal (evita o problema de "ovo e galinha":
o backend não pode ser criado pelo mesmo state que ele vai armazenar).

## Uso

```powershell
cd bootstrap
terraform init
terraform apply -var="bucket_name=togglemaster-terraform-state" -var="aws_region=us-east-1"
```

Depois de criado o bucket, ajuste `bucket` em `../backend.tf` para o mesmo nome
e rode `terraform init` no projeto raiz.

Este bootstrap usa state local (não precisa de backend remoto, pois é
executado uma única vez).
