module "subnets" {
  source          = "../network/private_subnet"
  name            = var.name
  cidrs           = var.subnets
  vpc_id          = var.vpc_id
  azs             = var.azs
  nat_support     = false
  nat_gateway_ids = []
}

resource "aws_efs_file_system" "efs" {
  creation_token   = var.name
  performance_mode = var.performance_mode

  throughput_mode                 = var.provisioned_throughput_in_mibps == null ? "bursting" : "provisioned"
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  encrypted                       = true

  lifecycle_policy {
    transition_to_ia = var.transition_to_ia
  }

  tags = {
    Name = var.name
  }

  lifecycle {
    prevent_destroy = "false"
  }
}

resource "aws_security_group" "efs_sg" {
  name   = var.name
  vpc_id = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    security_groups = var.security_group_ids
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }
}

resource "aws_efs_mount_target" "target" {
  count           = length(var.azs)
  subnet_id       = element(module.subnets.ids, count.index)
  file_system_id  = aws_efs_file_system.efs.id
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_route53_record" "efs" {
  name    = var.dns_name
  zone_id = var.route53_zone_id
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_efs_file_system.efs.id}.efs.${var.region}.amazonaws.com"]
}
