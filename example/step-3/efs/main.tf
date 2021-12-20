resource "k8s_core_v1_namespace" "this" {
  metadata {
    name = "efs"
    annotations = {
      "scheduler.alpha.kubernetes.io/node-selector" = "role=master"
    }
  }
}

module "efs-provisioner" {
  source    = "../../../../terraform-k8s-modules/modules/kubernetes/efs-provisioner"
  namespace = k8s_core_v1_namespace.this.metadata[0].name

  AWS_REGION     = var.aws_region
  FILE_SYSTEM_ID = var.file_system_id
  DNS_NAME       = var.dns_name
}

resource "k8s_storage_k8s_io_v1_storage_class" "efs" {
  metadata {
    name = "efs"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  _provisioner = module.efs-provisioner.provisioner
}
