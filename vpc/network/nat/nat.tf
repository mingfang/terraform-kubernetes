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
  count = "${length(var.azs)}"
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "${var.name}-eip"
  }

}

resource "aws_nat_gateway" "nat" {
  count         = "${length(var.azs)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(var.public_subnet_ids, count.index)}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "${var.name}"
  }
}

output "ids" {
  value = ["${aws_nat_gateway.nat.*.id}"]
}

output "public_ips" {
  value = ["${aws_nat_gateway.nat.*.public_ip}"]
}
