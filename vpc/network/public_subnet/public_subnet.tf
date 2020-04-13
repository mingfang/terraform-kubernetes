resource "aws_subnet" "subnets" {
  count                   = length(var.azs)
  vpc_id                  = var.vpc_id
  cidr_block              = element(var.cidrs, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}.${element(var.azs, count.index)}"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id

  route {
    gateway_id = var.internet_gateway_id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = var.name
  }
}

resource "aws_route_table_association" "route_association" {
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.subnets.*.id, count.index)
  route_table_id = aws_route_table.route_table.id
}

