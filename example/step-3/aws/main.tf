resource "k8s_core_v1_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

module "aws_node_termination_handler" {
  source    = "github.com/mingfang/terraform-k8s-modules/modules/aws/aws-node-termination-handler"
  namespace = k8s_core_v1_namespace.this.metadata[0].name

  ENABLE_SCHEDULED_EVENT_DRAINING   = "true"
  ENABLE_SPOT_INTERRUPTION_DRAINING = "true"
  EMIT_KUBERNETES_EVENTS            = "true"
  TAINT_NODE                        = "true"
  CHECK_ASG_TAG_BEFORE_DRAINING     = "false"
  NODE_TERMINATION_GRACE_PERIOD     = "60"
}

module "aws-cluster-autoscaler" {
  source    = "github.com/mingfang/terraform-k8s-modules/modules/aws/aws-cluster-autoscaler"
  namespace = k8s_core_v1_namespace.this.metadata[0].name
  node_selector = {
    "role" = "master"
  }
  CLUSTER_NAME = var.cluster_name
}

module "aws-cloud-provider" {
  source    = "github.com/mingfang/terraform-k8s-modules/modules/aws/aws-cloud-provider"
  namespace = k8s_core_v1_namespace.this.metadata[0].name
  node_selector = {
    "role" = "master"
  }
}