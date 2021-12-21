resource "k8s_core_v1_namespace" "this" {
  metadata {
    name = var.namespace
    annotations = {
      "scheduler.alpha.kubernetes.io/node-selector" = "role=green"
    }
  }
}

module "nginx" {
  source    = "github.com/mingfang/terraform-k8s-modules/modules/nginx"
  name      = var.name
  namespace = k8s_core_v1_namespace.this.metadata[0].name
}

resource "k8s_networking_k8s_io_v1beta1_ingress" "nginx" {
  metadata {
    annotations = {
      "kubernetes.io/ingress.class"              = "nginx"
      "nginx.ingress.kubernetes.io/server-alias" = "${var.namespace}.*"
    }
    name      = module.nginx.name
    namespace = k8s_core_v1_namespace.this.metadata[0].name
  }
  spec {
    rules {
      host = module.nginx.name
      http {
        paths {
          backend {
            service_name = module.nginx.name
            service_port = 80
          }
          path = "/"
        }
      }
    }
  }
}
