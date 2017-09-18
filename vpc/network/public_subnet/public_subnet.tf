# Variables

variable "name" {}

variable "vpc_id" {}

variable "cidrs" {
  type = "list"
}

variable "azs" {
  type = "list"
}

variable "internet_gateway_id" {
  default = ""
}

# Resources

resource "aws_subnet" "subnets" {
  count                   = "${length(var.cidrs)}"
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${element(var.cidrs, count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.name}.${element(var.azs, count.index)}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = "${var.vpc_id}"

  route {
    gateway_id = "${var.internet_gateway_id}"
    cidr_block = "0.0.0.0/0"
  }

  tags {
    Name = "${var.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table_association" "route_association" {
  count          = "${length(aws_subnet.subnets.*.id)}"
  subnet_id      = "${element(aws_subnet.subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.route_table.id}"

  lifecycle {
    create_before_destroy = true
  }
}

# Output

output "ids" {
  value = ["${aws_subnet.subnets.*.id}"]
}
