
# Module `example/step-3/efs`

Provider Requirements:
* **k8s ([mingfang/k8s](https://registry.terraform.io/providers/mingfang/k8s/latest))** (any version)

## Input Variables
* `aws_region` (required)
* `dns_name` (required)
* `file_system_id` (required)

## Output Values
* `storage_class_name`

## Managed Resources
* `k8s_core_v1_namespace.this` from `k8s`
* `k8s_storage_k8s_io_v1_storage_class.efs` from `k8s`

## Child Modules
* `efs-provisioner` from `github.com/mingfang/terraform-k8s-modules/modules/kubernetes/efs-provisioner`

