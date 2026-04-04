output "bucket_name" {
  description = "Name of the S3 state bucket."
  value       = aws_s3_bucket.tf_state.bucket
}
