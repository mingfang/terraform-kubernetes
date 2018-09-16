variable "ami_name" {}

variable "access_key" {}

variable "secret_key" {}

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

resource "null_resource" "packer" {
  triggers {
    ami_name = "${var.ami_name}"
  }

  provisioner "local-exec" {
    command = "packer build -var \"region=${var.region}\" -var \"vpc_id=${aws_vpc.vpc.id}\" -var \"subnet_id=${aws_subnet.subnet.id}\" -var \"ami_name=${var.ami_name}\" -var \"access_key=${var.access_key}\" -var \"secret_key=${var.secret_key}\" ${path.module}/kubernetes-ami.json"
  }
}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${var.ami_name}"]
  }

  depends_on = ["null_resource.packer"]
}

#Output

output "region" {
  value = "${var.region}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "subnet_id" {
  value = "${aws_subnet.subnet.id}"
}

output "ami_id" {
  value = "${data.aws_ami.ami.id}"
}
