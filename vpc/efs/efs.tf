# Variables

variable "name" {
}

variable "region" {
}

variable "vpc_id" {
}

variable "security_group_ids" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "subnets" {
  type = list(string)
}

variable "dns_name" {
}

variable "route53_zone_id" {
}

variable "performance_mode" {
  default = "generalPurpose"
}

variable "provisioned_throughput_in_mibps" {
  default = ""
}

# Resources

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

  throughput_mode                 = var.provisioned_throughput_in_mibps != "" ? "provisioned" : "bursting"
  provisioned_throughput_in_mibps = coalesce(var.provisioned_throughput_in_mibps, "1")
  encrypted                       = true

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

# Output

output "efs_id" {
  value = aws_efs_file_system.efs.id
}

output "fqdn" {
  value = aws_route53_record.efs.fqdn
}

