
# Module `example/step-3/aws`

Provider Requirements:
* **k8s ([mingfang/k8s](https://registry.terraform.io/providers/mingfang/k8s/latest))** (any version)

## Input Variables
* `cluster_name` (required)
* `namespace` (default `"aws"`)

## Managed Resources
* `k8s_core_v1_namespace.this` from `k8s`

## Child Modules
* `aws-cloud-provider` from [github.com/mingfang/terraform-k8s-modules/modules/aws/aws-cloud-provider](https://github.com/mingfang/terraform-k8s-modules/tree/master/modules/aws/aws-cloud-provider)
* `aws-cluster-autoscaler` from [github.com/mingfang/terraform-k8s-modules/modules/aws/aws-cluster-autoscaler](https://github.com/mingfang/terraform-k8s-modules/tree/master/modules/aws/aws-cluster-autoscaler)
* `aws_node_termination_handler` from [github.com/mingfang/terraform-k8s-modules/modules/aws/aws-node-termination-handler](https://github.com/mingfang/terraform-k8s-modules/tree/master/modules/aws/aws-node-termination-handler)

