module "vpc" {
  source = "../../vpc"
  name   = var.cluster_name
  region = var.region
  cidr   = var.cidr
}

module "network" {
  source                                  = "../../vpc/network"
  name                                    = var.cluster_name
  vpc_id                                  = module.vpc.this.id
  vpc_cidr                                = module.vpc.this.cidr_block
  azs                                     = var.azs
  public_subnets                          = var.public_subnets
  transit_gateway_destination_cidr_blocks = var.transit_gateway_destination_cidr_blocks
}

module "private_subnets" {
  source          = "../../vpc/network/private_subnet"
  name            = var.cluster_name
  cidrs           = var.private_subnets
  vpc_id          = local.vpc_id
  azs             = var.azs
  nat_gateway_ids = module.network.nat_gateway_ids
}

resource "aws_network_acl" "acl" {
  vpc_id = module.vpc.this.id

  subnet_ids = concat(module.network.public_subnet_ids, module.private_subnets.ids)

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
    Name = "${var.cluster_name}-all"
  }
}

locals {
  vpc_id                  = module.vpc.this.id
  vpc_main_route_table_id = module.vpc.this.main_route_table_id
  public_subnet_ids       = module.network.public_subnet_ids
  private_subnet_ids      = module.private_subnets.ids
}

