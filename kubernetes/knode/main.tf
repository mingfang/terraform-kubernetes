locals {
  name = "${var.cluster_name}-knodes-${var.zone}"
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

locals {
  docker_conf = templatefile("${path.module}/docker.conf", {
    insecure_registry = var.insecure_registry
    environments      = var.environments
  })

  start_sh = templatefile("${path.module}/start.sh", {
    role               = var.zone
    kmaster            = var.kmaster
    taints             = var.taints
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
  ebs_optimized = true
  update_default_version = true

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = var.security_group_ids
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      delete_on_termination = "true"
      volume_size           = var.volume_size
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
  desired_capacity          = var.size
  min_size                  = coalesce(var.min_size, var.size, 0)
  max_size                  = coalesce(var.max_size, var.size, 0)
  default_cooldown          = 60
  health_check_grace_period = 60
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = var.target_group_arns

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = var.on_demand_base_capacity != null ? var.on_demand_base_capacity : var.size
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

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = ""
    propagate_at_launch = false
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
    value               = ""
    propagate_at_launch = false
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/os"
    value               = "linux"
    propagate_at_launch = false
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/zone"
    value               = var.zone
    propagate_at_launch = false
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/role"
    value               = var.zone
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = var.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}
