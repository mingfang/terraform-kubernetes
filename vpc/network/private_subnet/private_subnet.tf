resource "aws_subnet" "subnets" {
  count                   = var.enable ? length(var.azs) : 0
  vpc_id                  = var.vpc_id
  cidr_block              = element(var.cidrs, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name}.${element(var.azs, count.index)}"
  }
}

resource "aws_route_table" "route_tables" {
  count  = var.enable && var.nat_support ? length(var.azs) : 0
  vpc_id = var.vpc_id

  route {
    nat_gateway_id = element(var.nat_gateway_ids, count.index)
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = "${var.name}.${element(var.azs, count.index)}"
  }
}

resource "aws_route_table_association" "route_association" {
  count          = var.enable && var.nat_support ? length(var.azs) : 0
  subnet_id      = element(aws_subnet.subnets.*.id, count.index)
  route_table_id = element(aws_route_table.route_tables.*.id, count.index)
}

