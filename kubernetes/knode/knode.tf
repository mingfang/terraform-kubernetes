# Variables


# Resources

module "subnets" {
  source          = "../../vpc/network/private_subnet"
  enable          = var.size > 0
  name            = var.name
  cidrs           = var.subnets
  vpc_id          = var.vpc_id
  azs             = var.azs
  nat_gateway_ids = var.nat_ids
}

resource "aws_iam_role" "iam_role" {
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

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.name}-profile"
  role = aws_iam_role.iam_role.name
}

resource "aws_iam_role_policy" "role_policy" {
  name = "${var.name}-policy"
  role = aws_iam_role.iam_role.id

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
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:DescribeVolumes"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF

}

module "alb" {
  source                  = "../../vpc/alb"
  enable                  = var.alb_enable
  name                    = var.name
  vpc_id                  = var.vpc_id
  subnet_ids              = var.alb_subnet_ids
  internal                = var.alb_internal
  dns_name_private        = var.alb_dns_name_private
  route53_zone_id_private = var.alb_route53_zone_id_private
  dns_names_public        = var.alb_dns_names_public
  route53_zone_id_public  = var.alb_route53_zone_id_public

  listeners_count = 2

  listeners = [
    {
      port         = 80
      protocol     = "HTTP"
      health_check = "/lbstatus"
    },
    {
      port            = 443
      protocol        = "HTTPS"
      health_check    = "/lbstatus"
      certificate_arn = var.certificate_arn
    },
  ]
}

data "template_file" "start" {
  template = file("${path.module}/start.sh")

  vars = {
    role    = var.zone
    kmaster = var.kmaster
    taints  = var.taints
  }
}

resource "aws_launch_template" "this" {
  count         = var.size > 0 ? 1 : 0
  name_prefix   = "${var.name}-"
  instance_type = var.instance_type
  image_id      = var.image_id
  key_name      = var.key_name
  user_data     = base64encode(data.template_file.start.rendered)

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.security_group_id]
    delete_on_termination       = true
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.volume_size
      volume_type           = "gp2"
      delete_on_termination = "true"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  count                     = var.size > 0 ? 1 : 0
  name_prefix               = "${var.name}-"
  desired_capacity          = var.size
  min_size                  = var.size
  max_size                  = var.size
  default_cooldown          = 60
  health_check_grace_period = 60
  vpc_zone_identifier       = module.subnets.ids
  target_group_arns         = module.alb.target_group_arns

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = var.on_demand_base_capacity != null ? var.on_demand_base_capacity : var.size
      on_demand_percentage_above_base_capacity = 0
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.this[0].id
        version            = "$Latest"
      }
    }
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Outputs

output "subnet_ids" {
  value = module.subnets.ids
}

