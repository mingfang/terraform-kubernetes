variable "name" {
  default = "example123"
  description = "the name of this cluster"
}

variable "public_domain" {
  description = "you public domain, e.g. example.com"
}

variable "ami_name" {}
variable "public_key_path" {}

variable "docker_config_json" {
  default = <<-EOF
  {
      "auths": {
          "https://index.docker.io/v1/": {
              "auth": "bWluZ2Zhbmc6MTg3ODZhYjMtMTMxYi00YTY1LThmNzMtZTBiYmM1MjU2YjVm"
          }
      }
  }
  EOF
}

