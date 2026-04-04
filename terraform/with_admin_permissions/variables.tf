variable "ssm_prefix" {
  description = "SSM parameter path prefix to read region and tf_bucket_name from."
  type        = string
  default     = "clusterspinner"
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
