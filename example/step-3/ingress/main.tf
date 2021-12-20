resource "k8s_core_v1_namespace" "this" {
  metadata {
    name = "ingress"
    annotations = {
      "scheduler.alpha.kubernetes.io/node-selector" = "role=com"
    }
  }
}

module "ingress-controller" {
  source        = "../../../../terraform-k8s-modules/modules/kubernetes/ingress-nginx"
  name          = "ingress-controller"
  namespace     = k8s_core_v1_namespace.this.metadata[0].name
  replicas      = 1
  ingress_class = "nginx"

  service_type            = "ClusterIP"
  external_traffic_policy = null

  config_map_data = {
    "client-header-buffer-size" = "4k"
  }

  container_ports = [
    {
      container_port = 80
      host_port      = 80
    },
    {
      container_port = 443
      host_port      = 443
    },
  ]
}
