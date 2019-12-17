# Variables

variable "name" {
}

variable "vpc_id" {
}

variable "vpc_cidr" {
}

variable "key_name" {
}

variable "subnet_id" {
}

variable "instance_type" {
  default = "t2.micro"
}

variable "image_id" {
}

variable "route53_zone_id" {
}

# Resources

data "template_file" "start" {
  template = file("${path.module}/start.sh")
}

resource "aws_security_group" "bastion" {
  name   = "${var.name}-sg"
  vpc_id = var.vpc_id

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = var.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "bastion" {
  ami                         = var.image_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    volume_size           = "8"
    volume_type           = "gp2"
    delete_on_termination = "true"
  }

  tags = {
    Name = var.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "bastion" {
  name    = "bastion"
  zone_id = var.route53_zone_id
  type    = "CNAME"
  ttl     = "300"
  records = [aws_instance.bastion.public_dns]
}

# Outputs

output "fqdn" {
  value = aws_route53_record.bastion.fqdn
}

