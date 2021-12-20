resource "aws_internet_gateway" "gw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name}-gw"
  }
}

module "nats" {
  source            = "./nat"
  name              = "${var.name}-nat"
  azs               = var.azs
  public_subnet_ids = module.public_subnets.ids
}

module "public_subnets" {
  source              = "./public_subnet"
  name                = "${var.name}-public"
  vpc_id              = var.vpc_id
  cidrs               = var.public_subnets
  azs                 = var.azs
  internet_gateway_id = aws_internet_gateway.gw.id
}
