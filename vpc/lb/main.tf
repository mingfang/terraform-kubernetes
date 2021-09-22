/* Security Group for ALB Only */
resource "aws_security_group" "sg" {
  count  = var.load_balancer_type == "application" ? 1 : 0
  name   = "${var.name}-lb-sg"
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "${var.name}-lb-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rules" {
  count             = var.load_balancer_type == "application" ? length(var.listeners) : 0
  security_group_id = var.load_balancer_type == "application" ? aws_security_group.sg[0].id : null
  type              = "ingress"
  protocol          = "TCP"
  from_port         = var.listeners[count.index]["port"]
  to_port           = var.listeners[count.index]["port"]

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

/* LB */
resource "aws_lb" "lb" {
  name = "${var.name}-lb"

  load_balancer_type = var.load_balancer_type
  internal           = var.internal
  subnets            = var.subnet_ids
  security_groups    = var.load_balancer_type == "application" ? [aws_security_group.sg[0].id] : null
  idle_timeout       = var.load_balancer_type == "application" ? var.idle_timeout : null
  enable_cross_zone_load_balancing = var.load_balancer_type == "network"
}

resource "aws_lb_target_group" "atg" {
  count       = length(var.listeners)
  name        = "${var.name}-${var.listeners[count.index]["port"]}"
  vpc_id      = var.vpc_id
  port        = var.listeners[count.index]["port"]
  protocol    = var.listeners[count.index]["protocol"]

  dynamic "stickiness" {
    for_each = var.load_balancer_type == "application" ? [1] : []
    content {
      type            = "lb_cookie"
      cookie_duration = 3600 //1 hour
    }
  }

  health_check {
    path                = var.load_balancer_type == "application" ? var.listeners[count.index]["health_check"] : null
    matcher             = var.load_balancer_type == "application" ? "200" : null
    timeout             = var.load_balancer_type == "application" ? 5 : null
    protocol            = var.listeners[count.index]["protocol"]
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "listener" {
  count             = length(var.listeners)
  load_balancer_arn = aws_lb.lb.arn
  port              = var.listeners[count.index]["port"]
  protocol          = var.listeners[count.index]["protocol"]
  certificate_arn   = lookup(var.listeners[count.index], "certificate_arn", "")

  default_action {
    target_group_arn = element(aws_lb_target_group.atg.*.arn, count.index)
    type             = "forward"
  }
}

/* DNS */
resource "aws_route53_record" "route53_records" {
  count   = length(var.dns_names)
  name    = element(var.dns_names, count.index)
  zone_id = var.route53_zone_id
  type    = "A"

  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }
}