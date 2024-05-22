locals {
  name = "${var.cluster_name}-kmaster"
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "aws_iam_role" "iam_role" {
  name = "${local.name}-role"

  assume_role_policy = <<-EOF
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

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${local.name}-profile"
  role = aws_iam_role.iam_role.name
}

resource "aws_iam_role_policy" "role_policy" {
  name = "${local.name}-policy"
  role = aws_iam_role.iam_role.id

  policy = file("${path.module}/iam-policy.json")
}

/* S3 Bucket for kmaster keys */
resource "aws_s3_bucket" "keys" {
  bucket_prefix = "${local.name}-keys-"
  acl           = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
resource "aws_s3_bucket_public_access_block" "keys" {
  bucket = aws_s3_bucket.keys.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

locals {
  docker_conf = templatefile("${path.module}/docker.conf", {
    insecure_registry = var.insecure_registry
    environments      = var.environments
  })

  start_sh = templatefile("${path.module}/start.sh", {
    vpc_id            = var.vpc_id
    efs_dns_name      = var.efs_dns_name
    bucket            = aws_s3_bucket.keys.id
    iam_role          = aws_iam_role.iam_role.id
    kubernetes_master = ""
    alt_names = join(",", compact([
      var.lb_private_fqdn,
      var.lb_public_fqdn,
    ]))
    cluster_cidr       = var.cluster_cidr
    docker_conf        = local.docker_conf
    docker_config_json = var.docker_config_json
  })
}

resource "aws_launch_template" "this" {
  name_prefix   = "${local.name}-${var.instance_type}"
  instance_type = var.instance_type
  image_id      = var.image_id
  key_name      = var.key_name
  user_data     = base64encode(local.start_sh)
  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = concat([aws_security_group.sg.id], var.security_group_ids)
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      delete_on_termination = "true"
      volume_size           = "24"
      volume_type           = "gp2"
    }
  }

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name_prefix               = "${local.name}-"
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1
  default_cooldown          = 60
  health_check_grace_period = 60
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = var.target_group_arns

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = var.use_spot ? 0 : 1
      on_demand_percentage_above_base_capacity = 0
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.this.id
        version            = "$Latest"
      }
    }
  }

  tag {
    key                 = "Name"
    value               = local.name
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = ""
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  depends_on = [aws_s3_bucket.keys]
}

resource "aws_security_group" "sg" {
  name   = local.name
  vpc_id = var.vpc_id

  //need for ARP to work; figure out the port later
  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }

  ingress {
    protocol    = "TCP"
    from_port   = 6443
    to_port     = 6443
    cidr_blocks = ["0.0.0.0/0"]
    description = "kmaster"
  }

  ingress {
    protocol    = "TCP"
    from_port   = 8200
    to_port     = 8200
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "vault"
  }

  ingress {
    protocol    = "TCP"
    from_port   = 10250
    to_port     = 10250
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "metrics"
  }

  //SSH
  ingress {
    protocol    = "TCP"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }

  //EFS
  egress {
    protocol    = "TCP"
    from_port   = 2049
    to_port     = 2049
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "EFS"
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.name
  }

  lifecycle {
    create_before_destroy = true
  }
}
