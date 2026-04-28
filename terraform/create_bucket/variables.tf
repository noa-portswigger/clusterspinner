# SPDX-FileCopyrightText: 2026 The clusterspinner contributors
# SPDX-License-Identifier: MIT

variable "bucket_name" {
  description = "Name of the S3 bucket to create for Terraform state."
  type        = string
}

variable "region" {
  description = "AWS region to create the bucket in."
  type        = string
}
