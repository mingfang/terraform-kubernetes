variable "region" {}

variable "az" {}

variable "name" {}

variable "vpc_cidr" {}

variable "subnet_cidr" {}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}-gw"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.subnet_cidr}"
  availability_zone       = "${var.az}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.name}-${var.az}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    gateway_id = "${aws_internet_gateway.gw.id}"
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
  subnet_id      = "${aws_subnet.subnet.id}"
  route_table_id = "${aws_route_table.route_table.id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "sg" {
  name   = "${var.name}-sg"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  tags {
    Name = "${var.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#Output

resource "local_file" "output" {
  filename = "${path.cwd}/packer_vars.json"
  content     = <<EOF
{
  "packer_region": "${var.region}",
  "packer_vpc_id": "${aws_vpc.vpc.id}",
  "packer_subnet_id": "${aws_subnet.subnet.id}"
}
EOF
}

output "region" {
  value = "${var.region}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "subnet_id" {
  value = "${aws_subnet.subnet.id}"
}
