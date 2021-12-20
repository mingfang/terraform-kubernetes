resource "k8s_core_v1_namespace" "this" {
  metadata {
    name = var.namespace
    annotations = {
      "scheduler.alpha.kubernetes.io/node-selector" = "role=green"
    }
  }
}

// grant admin to this namespace
resource "k8s_rbac_authorization_k8s_io_v1_role_binding" "admin" {
  metadata {
    name      = "admin"
    namespace = k8s_core_v1_namespace.this.metadata[0].name
  }

  subjects {
    kind = "ServiceAccount"
    name = "default"
  }
  role_ref {
    kind      = "ClusterRole"
    name      = "admin"
    api_group = "rbac.authorization.k8s.io"
  }
}

// volume to store project files
resource "k8s_core_v1_persistent_volume_claim" "data" {
  metadata {
    name      = "data"
    namespace = k8s_core_v1_namespace.this.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteMany"]
    resources { requests = { "storage" = "1Gi" } }
    storage_class_name = var.storage_class_name
  }
}

// IntelliJ with Docker In Docker(DinD) support
module "intellij" {
  source    = "../../../../terraform-k8s-modules/modules/intellij"
  name      = var.name
  namespace = k8s_core_v1_namespace.this.metadata[0].name

  env = [
    {
      name  = "DOCKER_HOST"
      value = "tcp://localhost:2375"
    }
  ]

  // add additional containers for your project such as db, messaging, etc
  additional_containers = [
    {
      name  = "dind"
      image = "docker:19-dind"
      args  = ["--insecure-registry=0.0.0.0/0"]
      env = [
        {
          name = "POD_NAME"
          value_from = {
            field_ref = {
              field_path = "metadata.name"
            }
          }
        },
        {
          name  = "DOCKER_TLS_CERTDIR"
          value = ""
        }
      ]
      security_context = {
        privileged = true
      }

      volume_mounts = [
        {
          name          = "data"
          mount_path    = "/var/lib/docker"
          sub_path_expr = ".docker/$(POD_NAME)/var/lib/docker"
        },
      ]
    }
  ]

  pvc = k8s_core_v1_persistent_volume_claim.data.metadata[0].name
}

// IntelliJ URL https://<namespace>.<your domain>
resource "k8s_networking_k8s_io_v1beta1_ingress" "this" {
  metadata {
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "nginx.ingress.kubernetes.io/server-alias"       = "${var.namespace}.*"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/enable-access-log"  = "false"
    }
    name      = module.intellij.name
    namespace = k8s_core_v1_namespace.this.metadata[0].name
  }
  spec {
    rules {
      host = "${module.intellij.name}-${var.namespace}"
      http {
        paths {
          path = "/"
          backend {
            service_name = module.intellij.name
            service_port = module.intellij.ports[0].port
          }
        }
      }
    }
  }
}

// Proxy to any port https://<namespace>-<port>.<your domain>
resource "k8s_networking_k8s_io_v1beta1_ingress" "proxy" {
  metadata {
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"

      "nginx.ingress.kubernetes.io/auth-url"              = "https://oauth.app.kkr.com/oauth2/auth"
      "nginx.ingress.kubernetes.io/auth-signin"           = "https://oauth.app.kkr.com/oauth2/start?rd=https://$host$escaped_request_uri"
      "nginx.ingress.kubernetes.io/auth-cache-key"        = "$cookie__oauth2_proxy"
      "nginx.ingress.kubernetes.io/auth-response-headers" = "X-Auth-Request-User, X-Auth-Request-Email"
      "nginx.ingress.kubernetes.io/server-snippet"        = <<-EOF
        server_name ~^${var.namespace}-(?<port>[0-9]+)\..*;
        location ~ / {
          resolver kube-dns.kube-system.svc.cluster.local valid=5s;
          proxy_pass http://${var.name}-0.${var.name}.${var.namespace}.svc.cluster.local:$port;

          proxy_redirect          off;
          proxy_set_header        Host            $host;
          proxy_set_header        X-Forwarded-Host $host;
          proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header        X-Forwarded-Proto $scheme;
          proxy_set_header        X-Real-IP       $remote_addr;

          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
          proxy_cache_bypass $http_upgrade;

          proxy_send_timeout                      3600s;
          proxy_read_timeout                      24h;
          client_max_body_size                    10240m;

          # this location requires authentication
          auth_request        /_external-auth-Lw;
          auth_request_set    $auth_cookie $upstream_http_set_cookie;
          add_header          Set-Cookie $auth_cookie;
          auth_request_set $authHeader0 $upstream_http_x_auth_request_user;
          proxy_set_header 'X-Auth-Request-User' $authHeader0;
          auth_request_set $authHeader1 $upstream_http_x_auth_request_email;
          proxy_set_header 'X-Auth-Request-Email' $authHeader1;

          set_escape_uri $escaped_request_uri $request_uri;
          error_page 401 = @44916ed7e40460051432f6c9543d963c7e98d186;
        }
        EOF
    }
    name      = "${module.intellij.name}-proxy"
    namespace = k8s_core_v1_namespace.this.metadata[0].name
  }
  spec {
    rules {
      host = "${module.intellij.name}-${var.namespace}-proxy"
      http {
        // not used; only to avoid syntax validation error
        paths {
          path = "/"
          backend {
            service_name = module.intellij.name
            service_port = module.intellij.ports[0].port
          }
        }
      }
    }
  }
}

