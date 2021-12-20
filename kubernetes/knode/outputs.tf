output "name" {
  value = local.name
}

output "cluster_name" {
  value = var.cluster_name
}

output "zone" {
  value = var.zone
}

output "size" {
  value = var.size
}

output "instance_type" {
  value = var.instance_type
}

output "launch_template" {
  value = aws_launch_template.this
}