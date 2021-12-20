
# Module `vpc/ebs_backup`

Provider Requirements:
* **archive:** (any version)
* **aws:** (any version)

## Input Variables
* `default_retention` (default `7`)
* `ebs_backup_delete_schedule` (default `"rate(12 hours)"`)
* `ebs_backup_schedule` (default `"rate(1 hour)"`)
* `name` (required)

## Managed Resources
* `aws_cloudwatch_event_rule.ebs_backup` from `aws`
* `aws_cloudwatch_event_rule.ebs_backup_delete` from `aws`
* `aws_cloudwatch_event_target.ebs_backup` from `aws`
* `aws_cloudwatch_event_target.ebs_backup_delete` from `aws`
* `aws_iam_role.ebs_backup_role` from `aws`
* `aws_iam_role_policy.ebs_backup_policy` from `aws`
* `aws_lambda_function.ebs_backup` from `aws`
* `aws_lambda_function.ebs_backup_delete` from `aws`
* `aws_lambda_permission.allow_cloudwatch_to_call_ebs_backup` from `aws`
* `aws_lambda_permission.allow_cloudwatch_to_call_ebs_backup_delete` from `aws`

## Data Resources
* `data.archive_file.ebs_backup_zip` from `archive`

