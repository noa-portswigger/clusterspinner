variable "region" {
  description = "AWS region."
  type        = string
}

variable "tf_state_bucket" {
  description = "Name of the S3 bucket used for Terraform state."
  type        = string
}

variable "cluster_names" {
  description = "List of EKS cluster names to grant permissions for."
  type        = list(string)
}

variable "trusted_principals" {
  description = "List of IAM principal ARNs allowed to assume the runner role."
  type        = list(string)
}

variable "zone_name" {
  description = "Route53 hosted zone name to create and manage."
  type        = string
}
