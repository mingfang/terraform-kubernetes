# Variables

variable "name" {}

variable "vpc_id" {}

variable "vpc_cidr" {}

variable "key_name" {}

variable "azs" {
  type = "list"
}

variable "subnets" {
  type = "list"
}

variable "nat_ids" {
  type = "list"
}

variable "instance_type" {}

variable "zone" {}

variable "size" {}

variable "alb_enable" {
  default = false
}

variable "alb_internal" {
  default = true
}

variable "alb_dns_name_private" {
  default = ""
}

variable "alb_dns_names_public" {
  type    = "list"
  default = []
}

variable "alb_route53_zone_id_private" {
  default = ""
}

variable "alb_route53_zone_id_public" {
  default = ""
}

variable "alb_subnet_ids" {
  type    = "list"
  default = []
}

variable "security_group_id" {}

variable "image_id" {}

variable "kmaster" {}

variable "certificate_arn" {
  default = ""
}

# Resources

module "subnets" {
  source          = "../../vpc/network/private_subnet"
  enable          = "${var.size > 0}"
  name            = "${var.name}"
  cidrs           = "${var.subnets}"
  vpc_id          = "${var.vpc_id}"
  azs             = "${var.azs}"
  nat_gateway_ids = "${var.nat_ids}"
}

module "alb" {
  source                  = "../../vpc/alb"
  enable                  = "${var.alb_enable}"
  name                    = "${var.name}"
  vpc_id                  = "${var.vpc_id}"
  subnet_ids              = ["${var.alb_subnet_ids}"]
  internal                = "${var.alb_internal}"
  dns_name_private        = "${var.alb_dns_name_private}"
  route53_zone_id_private = "${var.alb_route53_zone_id_private}"
  dns_names_public        = "${var.alb_dns_names_public}"
  route53_zone_id_public  = "${var.alb_route53_zone_id_public}"

  listeners = [
    {
      port         = 80
      protocol     = "HTTP"
      health_check = "/lbstatus"
    },
    {
      port            = 443
      protocol        = "HTTPS"
      health_check    = "/lbstatus"
      certificate_arn = "${var.certificate_arn}"
    },
  ]
}

data "template_file" "start" {
  template = "${file("${path.module}/start.sh")}"

  vars {
    zone    = "${var.zone}"
    kmaster = "${var.kmaster}"
  }
}

resource "aws_launch_configuration" "lc" {
  count                       = "${var.size > 0 ? 1: 0}"
  name_prefix                 = "${var.name}-"
  instance_type               = "${var.instance_type}"
  image_id                    = "${var.image_id}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${var.security_group_id}"]
  associate_public_ip_address = false
  user_data                   = "${data.template_file.start.rendered}"

  root_block_device {
    volume_size           = "16"
    volume_type           = "gp2"
    delete_on_termination = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  count                = "${var.size > 0 ? 1: 0}"
  name_prefix          = "${var.name}-"
  desired_capacity     = "${var.size}"
  min_size             = "${var.size}"
  max_size             = "${var.size}"
  default_cooldown     = 60
  launch_configuration = "${aws_launch_configuration.lc.name}"
  vpc_zone_identifier  = ["${module.subnets.ids}"]
  target_group_arns    = ["${module.alb.target_group_arns}"]

  tag {
    key                 = "Name"
    value               = "${var.name}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Outputs

output "subnet_ids" {
  value = "${module.subnets.ids}"
}
