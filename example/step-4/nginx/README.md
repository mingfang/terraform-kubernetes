
# Module `example/step-4/nginx`

Provider Requirements:
* **k8s ([mingfang/k8s](https://registry.terraform.io/providers/mingfang/k8s/latest))** (any version)

## Input Variables
* `name` (default `"nginx"`)
* `namespace` (default `"nginx"`)

## Managed Resources
* `k8s_core_v1_namespace.this` from `k8s`
* `k8s_networking_k8s_io_v1beta1_ingress.nginx` from `k8s`

## Child Modules
* `nginx` from [github.com/mingfang/terraform-k8s-modules/modules/nginx](https://github.com/mingfang/terraform-k8s-modules/tree/master/modules/nginx)

