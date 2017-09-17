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

variable "instance_type" {
  default = "t2.micro"
}

variable "image_id" {}

variable "efs_dns_name" {
  default = ""
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

# Resources

module "subnets" {
  source          = "../../vpc/network/private_subnet"
  name            = "${var.name}-kmaster"
  cidrs           = "${var.subnets}"
  vpc_id          = "${var.vpc_id}"
  azs             = "${var.azs}"
  nat_gateway_ids = "${var.nat_ids}"
}

module "alb" {
  source                  = "../../vpc/network/alb"
  name                    = "${var.name}"
  vpc_id                  = "${var.vpc_id}"
  subnet_ids              = ["${var.alb_subnet_ids}"]
  ports                   = ["8080", "4001"]
  protocols               = ["HTTP", "HTTP"]
  health_checks           = ["/healthz", "/health"]
  internal                = false                                //todo, should be true
  dns_name_private        = "kmaster"
  route53_zone_id_private = "${var.alb_route53_zone_id_private}"
  dns_names_public        = ["kmaster"]
  route53_zone_id_public  = "${var.alb_route53_zone_id_public}"
}

data "template_file" "start" {
  template = "${file("${path.module}/start.sh")}"

  vars {
    efs_dns_name = "${var.efs_dns_name}"
  }
}

resource "aws_launch_configuration" "lc" {
  name_prefix                 = "${var.name}"
  instance_type               = "${var.instance_type}"
  image_id                    = "${var.image_id}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${aws_security_group.sg.id}"]
  associate_public_ip_address = false
  user_data                   = "${data.template_file.start.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "${var.name}-asg"
  desired_capacity     = 1
  min_size             = 1
  max_size             = 1
  launch_configuration = "${aws_launch_configuration.lc.name}"
  vpc_zone_identifier  = ["${module.subnets.ids}"]
  target_group_arns    = ["${module.alb.target_group_arns}"]

  tag {
    key                 = "Name"
    value               = "${var.name}"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "sg" {
  name   = "${var.name}-sg"
  vpc_id = "${var.vpc_id}"

  //KMASTER
  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  //ETCD
  ingress {
    protocol    = "tcp"
    from_port   = 4001
    to_port     = 4001
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  //KMASTER
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  //SSH
  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    #todo
    cidr_blocks = ["0.0.0.0/0"]
  }

  //EFS
  egress {
    protocol    = "tcp"
    from_port   = 2049
    to_port     = 2049
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}-sg"
  }
}

# Outputs

output "subnet_ids" {
  value = "${module.subnets.ids}"
}

output "security_group_id" {
  value = "${aws_security_group.sg.id}"
}
