variable "name" {}

variable "ebs_backup_schedule" {
  default = "rate(1 hour)"
}

variable "ebs_backup_delete_schedule" {
  default = "rate(12 hours)"
}

variable "default_retention" {
  default = 7
}

resource "aws_iam_role" "ebs_backup_role" {
  name = "${var.name}-ebs-backup-role"

  assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
    EOF
}

resource "aws_iam_role_policy" "ebs_backup_policy" {
  name = "${var.name}-ebs_backup-policy"
  role = "${aws_iam_role.ebs_backup_role.id}"

  policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": ["logs:*"],
                "Resource": "arn:aws:logs:*:*:*"
            },
            {
                "Effect": "Allow",
                "Action": "ec2:Describe*",
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateSnapshot",
                    "ec2:DeleteSnapshot",
                    "ec2:CreateTags",
                    "ec2:ModifySnapshotAttribute",
                    "ec2:ResetSnapshotAttribute"
                ],
                "Resource": ["*"]
            }
        ]
    }
    EOF
}

// Backup Zip

data "archive_file" "ebs_backup_zip" {
  type        = "zip"
  source_file = "${path.module}/ebs_backup.py"
  output_path = "/tmp/${var.name}_ebs_backup.zip"
}

// Backup function

resource "aws_lambda_function" "ebs_backup" {
  filename         = "${data.archive_file.ebs_backup_zip.output_path}"
  function_name    = "${var.name}_ebs_backup"
  description      = "${var.name} EBS Backup"
  role             = "${aws_iam_role.ebs_backup_role.arn}"
  timeout          = 60
  handler          = "ebs_backup.ebs_backup"
  runtime          = "python2.7"
  source_code_hash = "${data.archive_file.ebs_backup_zip.output_base64sha256}"

  environment {
    variables {
      backup_name       = "${var.name}"
      default_retention = "${var.default_retention}"
    }
  }

  tags {
    Backup = "${var.name}"
  }
}

resource "aws_cloudwatch_event_rule" "ebs_backup" {
  name                = "${var.name}_ebs_backup"
  description         = "${var.name} Schedule EBS Backup"
  schedule_expression = "${var.ebs_backup_schedule}"
}

resource "aws_cloudwatch_event_target" "ebs_backup" {
  rule      = "${aws_cloudwatch_event_rule.ebs_backup.name}"
  target_id = "ebs_backup"
  arn       = "${aws_lambda_function.ebs_backup.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_ebs_backup" {
  statement_id  = "${var.name}_AllowExecutionFromCloudWatch_ebs_backup"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ebs_backup.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ebs_backup.arn}"
}

// Cleanup function

resource "aws_lambda_function" "ebs_backup_delete" {
  filename         = "${data.archive_file.ebs_backup_zip.output_path}"
  function_name    = "${var.name}_ebs_backup_delete"
  description      = "${var.name} Delete EBS Backups"
  role             = "${aws_iam_role.ebs_backup_role.arn}"
  timeout          = 60
  handler          = "ebs_backup.ebs_backup_delete"
  runtime          = "python2.7"
  source_code_hash = "${data.archive_file.ebs_backup_zip.output_base64sha256}"

  tags {
    Backup = "${var.name}"
  }
}

resource "aws_cloudwatch_event_rule" "ebs_backup_delete" {
  name                = "${var.name}_ebs_backup_delete"
  description         = "${var.name} Schedule EBS Backup Delete"
  schedule_expression = "${var.ebs_backup_delete_schedule}"
}

resource "aws_cloudwatch_event_target" "ebs_backup_delete" {
  rule      = "${aws_cloudwatch_event_rule.ebs_backup_delete.name}"
  target_id = "ebs_backup_delete"
  arn       = "${aws_lambda_function.ebs_backup_delete.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_ebs_backup_delete" {
  statement_id  = "${var.name}_AllowExecutionFromCloudWatch_ebs_backup_delete"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ebs_backup_delete.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ebs_backup_delete.arn}"
}
