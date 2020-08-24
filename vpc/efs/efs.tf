data "aws_vpc" "vpc" {
  id = var.vpc_id
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

resource "aws_efs_mount_target" "target" {
  count           = length(var.subnet_ids)
  subnet_id       = var.subnet_ids[count.index]
  file_system_id  = aws_efs_file_system.efs.id
  security_groups = [aws_security_group.mount_target.id]
}

resource "aws_route53_record" "efs" {
  name    = var.dns_name
  zone_id = var.route53_zone_id
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_efs_file_system.efs.id}.efs.${var.region}.amazonaws.com"]
}

resource "aws_security_group" "mount_target_client" {
  name        = "${var.name}-mount-target-client"
  vpc_id      = var.vpc_id

  tags = {
    Name =  "${var.name}-mount-target-client"
  }
}

resource "aws_security_group_rule" "efs_egress" {
  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id = aws_security_group.mount_target_client.id
  source_security_group_id = aws_security_group.mount_target.id
}

resource "aws_security_group" "mount_target" {
  name        = "${var.name}-mount-target"
  vpc_id      = var.vpc_id

  tags = {
    Name =  "${var.name}-mount-target"
  }
}

resource "aws_security_group_rule" "efs_ingress" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id = aws_security_group.mount_target.id
  source_security_group_id = aws_security_group.mount_target_client.id
}