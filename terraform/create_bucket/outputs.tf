# SPDX-FileCopyrightText: 2026 The clusterspinner contributors
# SPDX-License-Identifier: MIT

output "bucket_name" {
  description = "Name of the S3 state bucket."
  value       = aws_s3_bucket.tf_state.bucket
}
