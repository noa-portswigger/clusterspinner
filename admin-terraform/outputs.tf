output "role_name" {
  description = "Name of the IAM role that can run terraform-eks-small."
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "ARN of the IAM role that can run terraform-eks-small."
  value       = aws_iam_role.this.arn
}

output "policy_arn" {
  description = "ARN of the customer-managed policy attached to the role."
  value       = aws_iam_policy.terraform_eks_small.arn
}
