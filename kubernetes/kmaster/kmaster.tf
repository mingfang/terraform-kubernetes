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

variable "certificate_arn" {}

# Resources

module "subnets" {
  source          = "../../vpc/network/private_subnet"
  name            = "${var.name}"
  cidrs           = "${var.subnets}"
  vpc_id          = "${var.vpc_id}"
  azs             = "${var.azs}"
  nat_gateway_ids = "${var.nat_ids}"
}

resource "aws_iam_role" "kmaster_role" {
  name = "${var.name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Sid": "",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "kmaster_profile" {
  name = "${var.name}-profile"
  role = "${aws_iam_role.kmaster_role.name}"
}

resource "aws_iam_role_policy" "kmaster_policy" {
  name = "${var.name}-policy"
  role = "${aws_iam_role.kmaster_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "iam:GetInstanceProfile"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_elb" "public" {
  name                        = "${var.name}-public-elb"
  subnets                     = ["${var.alb_subnet_ids}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 500
  connection_draining         = true
  connection_draining_timeout = 10
  security_groups             = ["${aws_security_group.elb_sg.id}"]

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:443"
    interval            = 10
  }
}

resource "aws_elb" "private" {
  name                        = "${var.name}-private-elb"
  subnets                     = ["${module.subnets.ids}"]
  internal                    = true
  cross_zone_load_balancing   = true
  idle_timeout                = 500
  connection_draining         = true
  connection_draining_timeout = 10
  security_groups             = ["${aws_security_group.elb_sg.id}"]

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 4001
    instance_protocol = "tcp"
    lb_port           = 4001
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 8200
    instance_protocol = "tcp"
    lb_port           = 8200
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:443"
    interval            = 10
  }
}

resource "aws_security_group" "elb_sg" {
  name   = "${var.name}-elb-sg"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags {
    Name = "${var.name}-elb-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "private" {
  zone_id = "${var.alb_route53_zone_id_private}"
  name    = "kmaster"
  type    = "A"

  alias {
    name                   = "${aws_elb.private.dns_name}"
    zone_id                = "${aws_elb.private.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "public" {
  name    = "kmaster"
  zone_id = "${var.alb_route53_zone_id_public}"
  type    = "A"

  alias {
    name                   = "${aws_elb.public.dns_name}"
    zone_id                = "${aws_elb.public.zone_id}"
    evaluate_target_health = true
  }
}

data "template_file" "start" {
  template = "${file("${path.module}/start.sh")}"

  vars {
    efs_dns_name = "${var.efs_dns_name}"
    vpc_id       = "${var.vpc_id}"
    alt_names    = "${aws_route53_record.private.fqdn},${aws_route53_record.public.fqdn}"
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
  iam_instance_profile        = "${aws_iam_instance_profile.kmaster_profile.name}"

  root_block_device {
    volume_size           = "8"
    volume_type           = "gp2"
    delete_on_termination = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "${var.name}"
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1
  default_cooldown          = 60
  health_check_grace_period = 60
  launch_configuration      = "${aws_launch_configuration.lc.name}"
  vpc_zone_identifier       = ["${module.subnets.ids}"]
  load_balancers            = ["${aws_elb.private.id}", "${aws_elb.public.id}"]

  tag {
    key                 = "Name"
    value               = "${var.name}"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "sg" {
  name   = "${var.name}"
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

  //VAULT
  ingress {
    protocol    = "tcp"
    from_port   = 8200
    to_port     = 8200
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
    Name = "${var.name}"
  }
}

# Outputs

output "subnet_ids" {
  value = "${module.subnets.ids}"
}

output "security_group_id" {
  value = "${aws_security_group.sg.id}"
}

output "fqdn" {
  value = "${aws_route53_record.private.fqdn}"
}
