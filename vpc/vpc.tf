# Variables

variable "name" {}

variable "cidr" {}

variable "region" {}

# Resources

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

//data "aws_caller_identity" "current" {}
//
//resource "aws_cloudwatch_event_rule" "snap_tagged_ebs" {
//  name                = "snap-ebs-volumes"
//  description         = "Snapshot tagged EBS volumes"
//  schedule_expression = "rate(5 minutes)"
//}
//
//resource "aws_cloudwatch_event_target" "tagged_volumes" {
//  target_id = "ebs_vol_a"
//  rule      = "${aws_cloudwatch_event_rule.snap_tagged_ebs.name}"
//  arn       = "arn:aws:automation:${var.region}:${data.aws_caller_identity.current.account_id}:action/EBSCreateSnapshot/EBSCreateSnapshot_ebs_vol_a"
//  input     = "\"arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:volume/vol-${var.ebs_vol_a_id}\""
//}
//
//resource "aws_iam_role" "iam_for_lambda" {
//  name = "iam_for_lambda"
//
//  assume_role_policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": "sts:AssumeRole",
//      "Principal": {
//        "Service": "lambda.amazonaws.com"
//      },
//      "Effect": "Allow",
//      "Sid": ""
//    }
//  ]
//}
//EOF
//}
//
//resource "aws_lambda_function" "test_lambda" {
//  filename         = "lambda_function_payload.zip"
//  function_name    = "lambda_function_name"
//  role             = "${aws_iam_role.iam_for_lambda.arn}"
//  handler          = "exports.test"
//  source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
//
//  environment {
//    variables = {
//      foo = "bar"
//    }
//  }
//}

# Output

output "id" {
  value = "${aws_vpc.vpc.id}"
}

output "cidr" {
  value = "${aws_vpc.vpc.cidr_block}"
}
