
# Module `example/step-3`

Provider Requirements:
* **aws:** (any version)
* **k8s ([mingfang/k8s](https://registry.terraform.io/providers/mingfang/k8s/latest))** (any version)

## Input Variables
* `azs` (required)
* `cluster_name` (required): the name of this cluster
* `region` (required): choose your region

## Data Resources
* `data.aws_efs_file_system.efs` from `aws`

## Child Modules
* `aws` from `./aws`
* `efs` from `./efs`
* `ingress` from `./ingress`

