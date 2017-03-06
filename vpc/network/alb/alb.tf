# Variables

variable "name" {}

variable "vpc_id" {}

variable "ports" {
  type = "list"
}

variable "protocols" {
  type = "list"
}

variable "health_checks" {
  type = "list"
}

variable "subnet_ids" {
  type = "list"
}

variable "internal" {
  default = false
}

variable "enable" {
  default = true
}

variable "route53_zone_id" {}

variable "dns_name" {}

# Resources

resource "aws_alb" "alb" {
  count           = "${var.enable}"
  name            = "${var.name}-alb"
  subnets         = ["${var.subnet_ids}"]
  security_groups = ["${aws_security_group.sg.id}"]
  internal        = "${var.internal}"
}

resource "aws_alb_listener" "listener" {
  count             = "${var.enable ? length(var.ports) : 0}"
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = "${element(var.ports, count.index)}"
  protocol          = "${element(var.protocols, count.index)}"

  default_action {
    target_group_arn = "${element(aws_alb_target_group.atg.*.id, count.index)}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "atg" {
  count    = "${var.enable ? length(var.ports) : 0}"
  name     = "${var.name}-${element(var.ports, count.index)}-atg"
  vpc_id   = "${var.vpc_id}"
  port     = "${element(var.ports, count.index)}"
  protocol = "${element(var.protocols, count.index)}"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 3600        //1 hour
  }

  health_check {
    path                = "${element(var.health_checks, count.index)}"
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }
}

resource "aws_security_group" "sg" {
  count  = "${var.enable}"
  name   = "${var.name}-alb-sg"
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}-alb-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rules" {
  count             = "${var.enable ? length(var.ports) : 0}"
  security_group_id = "${aws_security_group.sg.id}"

  type        = "ingress"
  protocol    = "tcp"
  from_port   = "${element(var.ports, count.index)}"
  to_port     = "${element(var.ports, count.index)}"
  cidr_blocks = ["0.0.0.0/0"]                        //todo
}

resource "aws_route53_record" "alb" {
  count   = "${var.enable}"
  zone_id = "${var.route53_zone_id}"
  name    = "${var.dns_name}"
  type    = "A"

  alias {
    name                   = "${aws_alb.alb.dns_name}"
    zone_id                = "${aws_alb.alb.zone_id}"
    evaluate_target_health = true
  }
}

# Output

output "target_group_arns" {
  value = ["${aws_alb_target_group.atg.*.arn}"]
}
