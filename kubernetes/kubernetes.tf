resource "aws_key_pair" "cluster_key_pair" {
  key_name   = "${var.name}-key-pair"
  public_key = file(var.public_key_path)

  lifecycle {
    create_before_destroy = true
  }
}

module "vpc" {
  source = "../vpc"
  name   = "${var.name}-vpc"
  cidr   = var.vpc_cidr
  region = var.region
}

module "network" {
  source         = "../vpc/network"
  name           = var.name
  vpc_id         = module.vpc.this.id
  vpc_cidr       = module.vpc.this.cidr_block
  azs            = var.azs
  public_subnets = var.public_subnets
}

module "bastion" {
  source          = "../vpc/bastion"
  name            = "${var.name}-bastion"
  enable          = var.bastion_enable
  instance_type   = var.bastion_instance_type
  image_id        = var.ami_id
  key_name        = aws_key_pair.cluster_key_pair.key_name
  vpc_id          = module.vpc.this.id
  vpc_cidr        = var.vpc_cidr
  subnet_id       = length(module.network.public_subnet_ids) > 0 ? element(module.network.public_subnet_ids, 0) : null
  route53_zone_id = var.route53_zone_id
}

module "kmaster" {
  source                      = "./kmaster"
  name                        = "${var.name}-kmaster"
  instance_type               = var.kmaster_instance_type
  vpc_id                      = module.vpc.this.id
  vpc_cidr                    = var.vpc_cidr
  azs                         = var.azs
  nat_ids                     = module.network.nat_gateway_ids
  subnets                     = var.kmaster_subnets
  key_name                    = aws_key_pair.cluster_key_pair.key_name
  alb_route53_zone_id_private = module.network.route53_private.id
  alb_route53_zone_id_public  = var.route53_zone_id
  alb_subnet_ids              = module.network.public_subnet_ids
  image_id                    = var.ami_id
  efs_dns_name                = module.efs.fqdn
}

module "green_zone" {
  source            = "./knode"
  name              = "${var.name}-knodes-green"
  zone              = "green"
  size              = var.green_size
  instance_type     = var.green_instance_type
  vpc_id            = module.vpc.this.id
  vpc_cidr          = var.vpc_cidr
  azs               = var.azs
  nat_ids           = module.network.nat_gateway_ids
  subnets           = var.green_subnets
  key_name          = aws_key_pair.cluster_key_pair.key_name
  security_group_id = module.network.security_group_id
  image_id          = var.ami_id
  kmaster           = module.kmaster.private_fqdn
  volume_size       = var.green_volume_size
}

module "net_zone" {
  source            = "./knode"
  name              = "${var.name}-knodes-net"
  zone              = "net"
  size              = var.net_size
  instance_type     = var.net_instance_type
  subnets           = var.net_subnets
  vpc_id            = module.vpc.this.id
  vpc_cidr          = var.vpc_cidr
  azs               = var.azs
  nat_ids           = module.network.nat_gateway_ids
  key_name          = aws_key_pair.cluster_key_pair.key_name
  security_group_id = module.network.security_group_id
  image_id          = var.ami_id
  kmaster           = module.kmaster.private_fqdn
  volume_size       = var.net_volume_size
}

module "db_zone" {
  source            = "./knode"
  name              = "${var.name}-knodes-db"
  zone              = "db"
  size              = var.db_size
  instance_type     = var.db_instance_type
  subnets           = var.db_subnets
  vpc_id            = module.vpc.this.id
  vpc_cidr          = var.vpc_cidr
  azs               = var.azs
  nat_ids           = module.network.nat_gateway_ids
  key_name          = aws_key_pair.cluster_key_pair.key_name
  security_group_id = module.network.security_group_id
  image_id          = var.ami_id
  kmaster           = module.kmaster.private_fqdn
  volume_size       = var.db_volume_size
}

module "spot_zone" {
  source                  = "./knode"
  name                    = "${var.name}-knodes-spot"
  zone                    = "spot"
  size                    = var.spot_size
  instance_type           = var.spot_instance_type
  subnets                 = var.spot_subnets
  vpc_id                  = module.vpc.this.id
  vpc_cidr                = var.vpc_cidr
  azs                     = var.azs
  nat_ids                 = module.network.nat_gateway_ids
  key_name                = aws_key_pair.cluster_key_pair.key_name
  security_group_id       = module.network.security_group_id
  image_id                = var.ami_id
  kmaster                 = module.kmaster.private_fqdn
  volume_size             = var.spot_volume_size
  on_demand_base_capacity = 1
  taints                  = "spotInstance=true:NoSchedule"
}

module "admin_zone" {
  source            = "./knode"
  name              = "${var.name}-knodes-admin"
  zone              = "admin"
  size              = var.admin_size
  instance_type     = var.admin_instance_type
  subnets           = var.admin_subnets
  vpc_id            = module.vpc.this.id
  vpc_cidr          = var.vpc_cidr
  azs               = var.azs
  nat_ids           = module.network.nat_gateway_ids
  key_name          = aws_key_pair.cluster_key_pair.key_name
  security_group_id = module.network.security_group_id
  image_id          = var.ami_id
  kmaster           = module.kmaster.private_fqdn
  certificate_arn   = var.admin_certificate_arn
  volume_size       = var.admin_volume_size

  alb_enable                  = var.admin_size > 0
  alb_internal                = false
  alb_subnet_ids              = module.network.public_subnet_ids
  alb_dns_name_private        = "admin"
  alb_route53_zone_id_private = module.network.route53_private.id
  alb_dns_names_public = [
    "*.admin.${data.aws_route53_zone.public.name}"
  ]
  alb_route53_zone_id_public = var.route53_zone_id
}

module "com_zone" {
  source            = "./knode"
  name              = "${var.name}-knodes-com"
  zone              = "com"
  size              = var.com_size
  instance_type     = var.com_instance_type
  subnets           = var.com_subnets
  vpc_id            = module.vpc.this.id
  vpc_cidr          = var.vpc_cidr
  azs               = var.azs
  nat_ids           = module.network.nat_gateway_ids
  key_name          = aws_key_pair.cluster_key_pair.key_name
  security_group_id = module.network.security_group_id
  image_id          = var.ami_id
  kmaster           = module.kmaster.private_fqdn
  certificate_arn   = var.com_certificate_arn
  volume_size       = var.com_volume_size

  alb_enable                  = var.com_size > 0
  alb_internal                = false
  alb_subnet_ids              = module.network.public_subnet_ids
  alb_dns_name_private        = "com"
  alb_route53_zone_id_private = module.network.route53_private.id
  alb_dns_names_public = [
    "*.${data.aws_route53_zone.public.name}"
  ]
  alb_route53_zone_id_public = var.route53_zone_id
}

module "efs" {
  source  = "../vpc/efs"
  name    = "${var.name}-efs"
  vpc_id  = module.vpc.this.id
  region  = var.region
  azs     = var.azs
  subnets = var.efs_subnets
  security_group_ids = [
    module.network.security_group_id,
    module.kmaster.security_group_id,
  ]
  dns_name        = "cluster-data"
  route53_zone_id = module.network.route53_private.id
}

resource "aws_network_acl" "acl" {
  vpc_id = module.vpc.this.id

  subnet_ids = concat(
    module.network.public_subnet_ids,
    module.com_zone.subnet_ids,
    module.green_zone.subnet_ids,
    module.net_zone.subnet_ids,
    module.spot_zone.subnet_ids,
    module.admin_zone.subnet_ids,
    module.db_zone.subnet_ids,
    module.kmaster.subnet_ids,
  )

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.name}-all"
  }
}