variable "bastion_enable" {
  default = true
}

variable "bastion_instance_type" {
  default = "t3a.nano"
}

module "bastion" {
  source = "../../vpc/bastion"
  name   = "${var.cluster_name}-bastion"

  enable        = var.bastion_enable
  subnet_id     = local.public_subnet_ids[0]
  instance_type = var.bastion_instance_type

  vpc_id                      = local.vpc_id
  image_id                    = data.aws_ami.kubernetes.image_id
  key_name                    = aws_key_pair.cluster_key_pair.key_name
  route53_zone_id             = local.public_route53_zone_id
  associate_public_ip_address = true
}

output "bastion" {
  value = module.bastion
}