output "bucket-name" {
  description = "The name bucket"
  value       = [for v in aws_s3_bucket.this : v.bucket]
}

output "bucket-arn" {
  description = "The ARN of the bucket"
  value       = [for v in aws_s3_bucket.this: v.arn]
}

output "role_arn" {
  description = "Output IAM role ARNs"
  value       = [for v in aws_iam_role.this : v.arn]
}