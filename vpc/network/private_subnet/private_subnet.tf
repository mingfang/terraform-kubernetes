# Variables

variable "name" {}

variable "vpc_id" {}

variable "cidrs" {
  type = "list"
}

variable "azs" {
  type = "list"
}

variable "nat_gateway_ids" {
  type    = "list"
  default = []
}

# Resources

resource "aws_subnet" "subnets" {
  count             = "${length(var.cidrs)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(var.cidrs, count.index)}"
  availability_zone = "${element(var.azs, count.index)}"

  tags {
    Name = "${var.name}.${element(var.azs, count.index)}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "route_tables" {
  count  = "${length(var.cidrs)}"
  vpc_id = "${var.vpc_id}"

  route {
    nat_gateway_id = "${element(var.nat_gateway_ids, count.index)}"
    cidr_block     = "0.0.0.0/0"
  }

  tags {
    Name = "${var.name}.${element(var.azs, count.index)}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table_association" "route_association" {
  count          = "${length(var.cidrs)}"
  subnet_id      = "${element(aws_subnet.subnets.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.route_tables.*.id, count.index)}"

  lifecycle {
    create_before_destroy = true
  }
}

# Output

output "ids" {
  value = ["${aws_subnet.subnets.*.id}"]
}
