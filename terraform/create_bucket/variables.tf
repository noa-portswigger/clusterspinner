variable "bucket_name" {
  description = "Name of the S3 bucket to create for Terraform state."
  type        = string
}

variable "region" {
  description = "AWS region to create the bucket in."
  type        = string
}

variable "ssm_prefix" {
  description = "SSM parameter path prefix under which region and bucket name are stored."
  type        = string
  default     = "clusterspinner"
}
