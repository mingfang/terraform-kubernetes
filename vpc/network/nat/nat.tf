#--------------------------------------------------------------
# This module creates all resources necessary for NAT
#--------------------------------------------------------------

variable "name" {
  default = "nat"
}

variable "azs" {
  type = "list"
}

variable "public_subnet_ids" {
  type = "list"
}

resource "aws_eip" "nat" {
  vpc = true

  count = "${length(var.azs)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(var.public_subnet_ids, count.index)}"

  count = "${length(var.azs)}"

  lifecycle {
    create_before_destroy = true
  }
}

output "ids" {
  value = ["${aws_nat_gateway.nat.*.id}"]
}
