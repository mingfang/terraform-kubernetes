resource "aws_subnet" "subnets" {
  count                   = var.enable ? length(var.azs) : 0
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidrs[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name}.${var.azs[count.index]}"
  }
}

resource "aws_route_table" "route_tables" {
  count  = var.enable && var.nat_support ? length(var.azs) : 0
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name}.${var.azs[count.index]}"
  }
}

resource "aws_route" "nat" {
  count          = var.enable && var.nat_support ? length(var.azs) : 0
  route_table_id = aws_route_table.route_tables[count.index].id

  nat_gateway_id         = var.nat_gateway_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
}

// optional transit gateway route
resource "aws_route" "transit_gateway" {
  count          = var.transit_gateway_id == null ? 0 : length(var.azs) * length(var.transit_gateway_destination_cidr_blocks)
  route_table_id = element(aws_route_table.route_tables, count.index).id

  transit_gateway_id     = var.transit_gateway_id
  destination_cidr_block = var.transit_gateway_destination_cidr_blocks[floor(count.index / length(var.azs))]
}

resource "aws_route_table_association" "route_association" {
  count          = var.enable && var.nat_support ? length(var.azs) : 0
  subnet_id      = aws_subnet.subnets.*.id[count.index]
  route_table_id = aws_route_table.route_tables.*.id[count.index]
}

