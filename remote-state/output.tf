output "s3" {
  value = aws_s3_bucket.terraform_state
}

output "dynamodb" {
  value = aws_dynamodb_table.terraform_locks
}